# ==============================================================
# CIS Check: 18.10.26.2.1 (L1) - Audit Script
# Description: Ensure 'Security: Control Event Log behavior when the log file reaches its maximum size' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Event Log Service > Security > Control Event Log behavior when the log file reaches its maximum size
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security\Retention
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "0"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"
$ValueName = "Retention"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.26.2.1: Ensure 'Security Log Retention' is Disabled (0)"
Write-Host "=============================================================="

function Get-SecurityEventLogRetentionValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null # ถือว่าไม่ผ่านหากไม่มีการกำหนดค่านโยบายนี้ไว้อย่างชัดเจน
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [string]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-SecurityEventLogRetentionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Disabled ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Disabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }