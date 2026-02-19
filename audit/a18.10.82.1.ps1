# ==============================================================
# CIS Check: 18.10.82.1 (L1) - Audit Script
# Description: Ensure 'Configure the transmission of the user's password in MPR notifications' is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableMPR
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName = "EnableMPR"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.82.1: Check MPR Password Transmission Status"
Write-Host "=============================================================="

function Get-MPRStatus {
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

$CurrentValue = Get-MPRStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled/Secure)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - MPR Password Transmission is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). MPR is sending user passwords!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }