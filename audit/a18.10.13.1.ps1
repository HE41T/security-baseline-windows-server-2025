# ==============================================================
# CIS Check: 18.10.13.1 (L1) - Audit Script
# Description: Ensure 'Turn off cloud consumer account state content' is set to 'Enabled'
# GPO Path: Computer Configuration > Policies > Administrative Templates > Windows Components > Cloud Content > Turn off cloud consumer account state content
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableConsumerAccountStateContent
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$ValueName = "DisableConsumerAccountStateContent"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.13.1: Ensure 'Turn off cloud consumer account state content' is Enabled"
Write-Host "=============================================================="

function Get-CloudConsumerAccountStateValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 0
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-CloudConsumerAccountStateValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Enabled ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Enabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }