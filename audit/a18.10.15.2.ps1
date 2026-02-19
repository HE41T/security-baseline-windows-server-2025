# ==============================================================
# CIS Check: 18.10.15.2 (L1) - Audit Script
# Description: Ensure 'Enumerate administrator accounts on elevation' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Credential User Interface > Enumerate administrator accounts on elevation
# Registry Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI\EnumerateAdministrators
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\CredUI"
$ValueName = "EnumerateAdministrators"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.15.2: Ensure 'Enumerate administrator accounts on elevation' is Disabled"
Write-Host "=============================================================="

function Get-EnumerateAdministratorsValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null # ถือว่าไม่ผ่านเกณฑ์หากไม่มี Key นี้ (ต้องถูกระบุอย่างชัดเจน)
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-EnumerateAdministratorsValue

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