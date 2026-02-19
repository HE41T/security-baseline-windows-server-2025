# ==============================================================
# CIS Check: 18.10.18.6 (L1) - Audit Script
# Description: Ensure 'Enable App Installer Microsoft Store Source Certificate Validation Bypass' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Desktop App Installer > Enable App Installer Microsoft Store Source Certificate Validation Bypass
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller\EnableMicrosoftStoreSourceCertificateValidationBypass
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
$ValueName = "EnableMicrosoftStoreSourceCertificateValidationBypass"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.18.6: Ensure 'Enable App Installer Microsoft Store Source Certificate Validation Bypass' is Disabled"
Write-Host "=============================================================="

function Get-AppInstallerCertValidationBypassValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null # ถือว่าไม่ผ่านหากไม่มี Key นี้นะครับ (ต้องมีระบุไว้เพื่อบังคับปิดชัดเจน)
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-AppInstallerCertValidationBypassValue

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