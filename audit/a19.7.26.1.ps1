# ==============================================================
# CIS Check: 19.7.26.1 (L1) - Audit Script
# Description: Ensure 'Prevent users from sharing files within their profile.' is set to 'Enabled'
# Registry Path: HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoInplaceSharing
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$ValueName = "NoInplaceSharing"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.26.1: Check User Profile File Sharing Status"
Write-Host "=============================================================="

function Get-InplaceSharingStatus {
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

$CurrentValue = Get-InplaceSharingStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default allows sharing)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Profile sharing is PREVENTED)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Users can STILL share files from their profile!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }