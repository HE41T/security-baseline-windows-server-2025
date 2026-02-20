# ==============================================================
# CIS Check: 18.10.89.1.1 (L1) - Audit Script
# Description: Ensure 'Allow Basic authentication' for WinRM Client is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\AllowBasic
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
$ValueName = "AllowBasic"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.89.1.1: Check WinRM Client Basic Auth Status"
Write-Host "=============================================================="

function Get-WinRMClientBasicAuth {
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

$CurrentValue = Get-WinRMClientBasicAuth

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled/Secure)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Basic Auth is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). WinRM Client is ALLOWING Basic Auth!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }