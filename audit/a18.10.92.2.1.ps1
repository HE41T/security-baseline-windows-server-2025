# ==============================================================
# CIS Check: 18.10.92.2.1 (L1) - Audit Script
# Description: Ensure 'Prevent users from modifying settings' (Exploit Protection) is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection\DisallowExploitProtectionOverride
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection"
$ValueName = "DisallowExploitProtectionOverride"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.92.2.1: Check Exploit Protection Modification Restriction"
Write-Host "=============================================================="

function Get-ExploitProtectOverrideStatus {
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

$CurrentValue = Get-ExploitProtectOverrideStatus

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default allows modification)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Users are PREVENTED from modifying settings)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Users can STILL modify Exploit Protection!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }