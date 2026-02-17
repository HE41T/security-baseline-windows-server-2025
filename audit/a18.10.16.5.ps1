# ==============================================================
# CIS Check: 18.10.16.5 (L1) - Audit Script
# Description: Ensure 'Enable OneSettings Auditing' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Enable OneSettings auditing
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
$ValueName = "EnableOneSettingsAuditing"
$DesiredValue = 1

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.16.5: Ensure 'Enable OneSettings Auditing' is Enabled"
Write-Host "=============================================================="

function Get-OneSettingsAuditingValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 0
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Failed reading registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-OneSettingsAuditingValue

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
