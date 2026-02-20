# ==============================================================
# CIS Check: 18.10.15.1 (L1) - Audit Script
# Description: Ensure 'Do not display the password reveal button' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Credential User Interface > Do not display the password reveal button
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI\DisablePasswordReveal
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI"
$ValueName = "DisablePasswordReveal"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.15.1: Ensure 'Do not display the password reveal button' is Enabled"
Write-Host "=============================================================="

function Get-PasswordRevealValue {
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

$CurrentValue = Get-PasswordRevealValue

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