# ==============================================================
# CIS Check: 18.10.93.4.1 (L1) - Audit Script
# Description: Ensure 'Manage preview builds' is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\ManagePreviewBuildsPolicyValue
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$ValueName = "ManagePreviewBuildsPolicyValue"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.4.1: Check Preview Builds Management"
Write-Host "=============================================================="

function Get-PreviewBuildStatus {
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

$CurrentValue = Get-PreviewBuildStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Preview Builds are Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Preview Builds might be ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }