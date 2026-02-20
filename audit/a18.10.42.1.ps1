# ==============================================================
# CIS Check: 18.10.42.1 (L1) - Audit Script
# Description: Ensure 'Block all consumer Microsoft account user authentication' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Microsoft Account > Block all consumer Microsoft account user authentication
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messenger\Client\MicrosoftAccountConsumerAuthentication
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messenger\Client"
$ValueName = "MicrosoftAccountConsumerAuthentication"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.42.1: Ensure Consumer Microsoft Account Auth is Blocked"
Write-Host "=============================================================="

function Get-MSAccountBlockValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-MSAccountBlockValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Enabled (Block active: $CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Blocked)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }