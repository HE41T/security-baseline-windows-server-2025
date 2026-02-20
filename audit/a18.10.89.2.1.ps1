# ==============================================================
# CIS Check: 18.10.89.2.1 (L1) - Audit Script
# Description: Ensure 'Allow Basic authentication' for WinRM Service is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowBasic
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
$ValueName = "AllowBasic"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.89.2.1: Check WinRM Service Basic Auth Status"
Write-Host "=============================================================="

function Get-WinRMServiceBasicAuth {
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

$CurrentValue = Get-WinRMServiceBasicAuth

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Basic Auth is Rejected)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). WinRM Service is ACCEPTING Basic Auth!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }