# ==============================================================
# CIS Check: 19.7.44.1 (L1) - Audit Script
# Description: Ensure 'Always install with elevated privileges' (User) is set to 'Disabled'
# Registry Path: HKCU:\Software\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKCU:\Software\Policies\Microsoft\Windows\Installer"
$ValueName = "AlwaysInstallElevated"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.44.1: Check Always Install Elevated (User Level)"
Write-Host "=============================================================="

function Get-UserAlwaysInstallStatus {
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

$CurrentValue = Get-UserAlwaysInstallStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled/Secure)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Elevation is Disabled for User)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Elevation is ENABLED for User! (High Risk)" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }