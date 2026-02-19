# ==============================================================
# CIS Check: 1.2.1 (L1) - Audit Script
# Description: Ensure 'Account lockout duration' is set to '15 or more minute(s)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 15

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.2.1: Ensure 'Account lockout duration' is >= $DesiredValue"
Write-Host "=============================================================="

try {
    # Look for "Lockout duration (minutes)"
    $NetOutput = net accounts | Select-String "Lockout duration"
    
    if ($NetOutput) {
        $ValueString = $NetOutput.ToString() -replace "[^0-9]", ""
        
        if ([string]::IsNullOrWhiteSpace($ValueString)) {
            $CurrentValue = 0 
        } else {
            $CurrentValue = [int]$ValueString
        }
    } else {
        # If threshold is 0, duration might not be shown or is irrelevant, but CIS requires setting it.
        # Assuming parsing failure means it's not set correctly or threshold is 0.
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