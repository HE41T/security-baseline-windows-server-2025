# ==============================================================
# CIS Check: 18.10.93.2.2 (L1) - Audit Script
# Description: Ensure 'Configure Automatic Updates: Scheduled install day' is set to '0 - Every day'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\ScheduledInstallDay
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
$ValueName = "ScheduledInstallDay"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.2.2: Check Scheduled Install Day"
Write-Host "=============================================================="

function Get-ScheduledDayValue {
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

$CurrentValue = Get-ScheduledDayValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Scheduled for Every Day)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Updates are NOT scheduled daily!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }