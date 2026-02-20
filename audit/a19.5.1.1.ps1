# ==============================================================
# CIS Check: 19.5.1.1 (L1) - Audit Script
# Description: Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled'
# Registry Path: HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications\NoToastApplicationNotificationOnLockScreen
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$ValueName = "NoToastApplicationNotificationOnLockScreen"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.5.1.1: Check Toast Notifications on Lock Screen"
Write-Host "=============================================================="

function Get-LockScreenToastStatus {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return $null
    }
}

$CurrentValue = Get-LockScreenToastStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default allows notifications)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Toast Notifications are Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Notifications are ALLOWED on Lock Screen!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }