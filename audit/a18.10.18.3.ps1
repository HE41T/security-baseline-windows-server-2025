# ==============================================================
# CIS Check: 18.10.18.3 (L1) - Audit Script
# Description: Ensure 'Enable App Installer Hash Override' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Desktop App Installer > Enable App Installer Hash Override
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller\EnableHashOverride
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
$ValueName = "EnableHashOverride"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.18.3: Ensure 'Enable App Installer Hash Override' is Disabled"
Write-Host "=============================================================="

function Get-AppInstallerHashOverrideValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null # ถือว่าไม่ผ่านหากไม่มี Key นี้กำหนดไว้อย่างชัดเจน
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-AppInstallerHashOverrideValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Disabled ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Disabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }