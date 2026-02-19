# ==============================================================
# CIS Check: 1.2.2 (L1) - Audit Script
# Description: Ensure 'Account lockout threshold' is set to '5 or fewer invalid logon attempt(s), but not 0' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$MaxLimit = 5
$MinLimit = 1

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.2.2: Ensure 'Account lockout threshold' is <= $MaxLimit and > 0"
Write-Host "=============================================================="

try {
    # Look for "Lockout threshold"
    $NetOutput = net accounts | Select-String "Lockout threshold"
    
    if ($NetOutput) {
        $ValueString = $NetOutput.ToString() -replace "[^0-9]", ""
        if ([string]::IsNullOrWhiteSpace($ValueString)) {
            $CurrentValue = 0 
        } else {
            $CurrentValue = [int]$ValueString
        }
    } else {
        throw "Could not parse 'net accounts' output."
    }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -le $MaxLimit -and $CurrentValue -ge $MinLimit) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: 1 to $MaxLimit" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }