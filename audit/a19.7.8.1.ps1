# ==============================================================
# CIS Check: 19.7.8.1 (L1) - Audit Script
# Description: Ensure 'Configure Windows spotlight on lock screen' is set to 'Disabled'
# Registry Path: HKCU:\Software\Policies\Microsoft\Windows\CloudContent\ConfigureWindowsSpotlight
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 2
$RegPath = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
$ValueName = "ConfigureWindowsSpotlight"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.8.1: Check Windows Spotlight on Lock Screen"
Write-Host "=============================================================="

function Get-SpotlightStatus {
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

$CurrentValue = Get-SpotlightStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Enabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Windows Spotlight is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Windows Spotlight is ENABLED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }