# ==============================================================
# CIS Check: 18.10.18.2 (L1) - Audit Script
# Description: Ensure 'Enable App Installer Experimental Features' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > App Installer > Enable App Installer Experimental Features
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppInstaller
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppInstaller"
$ValueName = "EnableExperimentalFeatures"
$DesiredValue = 0

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.18.2: Ensure 'Enable App Installer Experimental Features' is Disabled"
Write-Host "=============================================================="

function Get-ExperimentalFeaturesValue {
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

$CurrentValue = Get-ExperimentalFeaturesValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
} elseif ($CurrentValue -eq $DesiredValue) {
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
