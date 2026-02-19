# ==============================================================
# CIS Check: 18.10.43.16 (L1) - Audit Script
# Description: Ensure 'Configure detection for potentially unwanted applications' is set to 'Enabled: Block'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\PUAProtection
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$ValueName = "PUAProtection"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.16: Check PUA Protection Status"
Write-Host "=============================================================="

function Get-PUAProtectionValue {
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

$CurrentValue = Get-PUAProtectionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - PUA Protection is Active)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). PUA Protection is NOT set to Block!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }