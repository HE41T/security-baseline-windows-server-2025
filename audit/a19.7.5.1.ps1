# ==============================================================
# CIS Check: 19.7.5.1 (L1) - Audit Script
# Description: Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled'
# Registry Path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments\SaveZoneInformation
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 2
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments"
$ValueName = "SaveZoneInformation"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.5.1: Check Preservation of File Zone Information"
Write-Host "=============================================================="

function Get-ZoneInfoPreservation {
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

$CurrentValue = Get-ZoneInfoPreservation

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Enabled/Secure)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Zone Information is Preserved)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Zone Information is NOT being preserved!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }