# ==============================================================
# CIS Check: 1.2.4 (L1) - Audit Script
# Description: Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 15

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.2.4: Ensure 'Reset account lockout counter' is >= $DesiredValue"
Write-Host "=============================================================="

try {
    # Look for "Lockout observation window"
    $NetOutput = net accounts | Select-String "Lockout observation window"
    
    if ($NetOutput) {
        $ValueString = $NetOutput.ToString() -replace "[^0-9]", ""
        if ([string]::IsNullOrWhiteSpace($ValueString)) {
            $CurrentValue = 0 
        } else {
            $CurrentValue = [int]$ValueString
        }
    } else {
        # Likely not set or Threshold is 0
        $CurrentValue = 0
    }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -ge $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue or more" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }