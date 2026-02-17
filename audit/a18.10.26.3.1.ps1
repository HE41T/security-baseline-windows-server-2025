# ==============================================================
# CIS Check: 18.10.26.3.1 (L1) - Audit Script
# Description: Ensure 'Setup: Control Event Log behavior when the log file reaches its maximum size' is set to 'Disabled' (Automated)
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\EventLog\\Setup"
$ValueName = "Retention"
$DesiredValue = "0"
$ValueType = "String"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.26.3.1: Ensure 'Setup: Control Event Log behavior when the log file reaches its maximum size' is set to 'Disabled' (Automated)"
Write-Host "=============================================================="

function Get-PolicyValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        if ($ValueType -eq "DWord") {
            return [int]$Value
        }
        return [string]$Value
    } catch {
        Write-Host "[!] Failed reading registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-PolicyValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
} elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Current value is $CurrentValue. Policy is compliant." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Current value is $CurrentValue. Expected: $DesiredValue." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
