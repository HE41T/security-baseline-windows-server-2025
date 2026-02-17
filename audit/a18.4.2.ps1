# ==============================================================
# CIS Check: 18.4.2 (L1) - Audit Script
# Description: Ensure 'Configure SMB v1 client driver' is set to 'Enabled: Disable driver'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 4 # 4 = Disabled
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10"
$RegName = "Start"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.4.2: Ensure SMB v1 client driver is Disabled ($DesiredValue)"
Write-Host "=============================================================="

try {
    $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($RegData -and $RegData.$RegName -ne $null) {
        $CurrentValue = [int]$RegData.$RegName
    } else { $CurrentValue = -1 }
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
    $ShowVal = if ($CurrentValue -eq -1) { "Not Configured" } else { $CurrentValue }
    Write-Host "Value is incorrect ($ShowVal). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }