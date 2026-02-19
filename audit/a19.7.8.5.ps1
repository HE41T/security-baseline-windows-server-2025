# ==============================================================
# CIS Check: 19.7.8.5 (L1) - Audit Script
# Description: Ensure 'Turn off Spotlight collection on Desktop' is set to 'Enabled'
# Registry Path: HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableSpotlightCollectionOnDesktop
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$ValueName = "DisableSpotlightCollectionOnDesktop"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.8.5: Check Spotlight Collection on Desktop Status"
Write-Host "=============================================================="

function Get-DesktopSpotlightStatus {
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

$CurrentValue = Get-DesktopSpotlightStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default allows Spotlight on Desktop)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Spotlight on Desktop is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Spotlight on Desktop is ENABLED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }