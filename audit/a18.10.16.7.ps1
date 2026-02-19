# ==============================================================
# CIS Check: 18.10.16.7 (L1) - Audit Script
# Description: Ensure 'Limit Dump Collection' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Limit Dump Collection
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\LimitDumpCollection
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$ValueName = "LimitDumpCollection"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.16.7: Ensure 'Limit Dump Collection' is Enabled"
Write-Host "=============================================================="

function Get-LimitDumpCollectionValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 0
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-LimitDumpCollectionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Enabled ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Enabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }