# ==============================================================
# CIS Check: 18.10.15.2 (L1) - Audit Script
# Description: Ensure 'Enumerate administrator accounts on elevation' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > System > Credentials Delegation > Enumerate administrator accounts on elevation
# Registry Path: HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\CredUI
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\CredUI"
$ValueName = "EnumerateAdministrators"
$DesiredValue = 0

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.15.2: Ensure 'Enumerate administrator accounts on elevation' is Disabled"
Write-Host "=============================================================="

function Get-EnumerateAdministratorsValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 1
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Failed reading registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-EnumerateAdministratorsValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is $CurrentValue. Policy is compliant." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Current value is $CurrentValue. Expected: $DesiredValue." -ForegroundColor Red
    Write-Host "Policy is not compliant." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
