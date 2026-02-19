# ==============================================================
# CIS Check: 19.7.5.2 (L1) - Audit Script
# Description: Ensure 'Notify antivirus programs when opening attachments' is set to 'Enabled'
# Registry Path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments\ScanWithAntiVirus
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 3
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments"
$ValueName = "ScanWithAntiVirus"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.5.2: Check Antivirus Notification for Attachments"
Write-Host "=============================================================="

function Get-AVNotificationStatus {
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

$CurrentValue = Get-AVNotificationStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - AV Notification is ENABLED)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Antivirus is NOT being notified!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }