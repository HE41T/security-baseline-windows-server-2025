# ==============================================================
# CIS Check: 18.10.81.2 (L1) - Audit Script
# Description: Ensure 'Always install with elevated privileges' is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"
$ValueName = "AlwaysInstallElevated"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.81.2: Check Always Install with Elevated Privileges"
Write-Host "=============================================================="

function Get-AlwaysInstallValue {
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

$CurrentValue = Get-AlwaysInstallValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Elevation is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Always Install Elevated is ENABLED! (High Risk)" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }