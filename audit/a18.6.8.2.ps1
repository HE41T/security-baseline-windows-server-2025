# ==============================================================
# CIS Check: 18.6.8.2 (L1) - Audit Script
# Description: Ensure 18.6.8.2 AuditClientDoesNotSupportEncryption is set to 1
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$RegName = "AuditClientDoesNotSupportEncryption"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.6.8.2: $RegName must be $DesiredValue"
Write-Host "=============================================================="

try {
    $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($RegData -and $RegData.$RegName -ne $null) {
        $CurrentValue = $RegData.$RegName
    } else { $CurrentValue =  }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    $ShowVal = if ($CurrentValue -eq $null) { "Not Configured" } else { $CurrentValue }
    Write-Host "Value is incorrect ($ShowVal). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
