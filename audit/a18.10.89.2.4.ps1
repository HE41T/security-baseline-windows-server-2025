# ==============================================================
# CIS Check: 18.10.89.2.4 (L1) - Audit Script
# Description: Ensure 'Disallow WinRM from storing RunAs credentials' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\DisableRunAs
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
$ValueName = "DisableRunAs"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.89.2.4: Check WinRM RunAs Credential Storage"
Write-Host "=============================================================="

function Get-WinRMDisableRunAs {
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

$CurrentValue = Get-WinRMDisableRunAs

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled/Risk)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - RunAs Credential Storage is Blocked)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). WinRM is ALLOWED to store RunAs credentials!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }