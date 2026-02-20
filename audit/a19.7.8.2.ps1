# ==============================================================
# CIS Check: 19.7.8.2 (L1) - Audit Script
# Description: Ensure 'Do not suggest third-party content in Windows spotlight' is set to 'Enabled'
# Registry Path: HKCU:\Software\Policies\Microsoft\Windows\CloudContent\DisableThirdPartySuggestions
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
$ValueName = "DisableThirdPartySuggestions"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.8.2: Check Third-Party Content Suggestions"
Write-Host "=============================================================="

function Get-ThirdPartySuggestStatus {
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

$CurrentValue = Get-ThirdPartySuggestStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default allows suggestions)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Third-Party Suggestions are Blocked)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Third-Party Suggestions are ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }