# ==============================================================
# CIS Check: 18.10.14.1 (L1) - Audit Script
# Description: Ensure 'Require PIN for pairing' is set to 'Enabled: First Time' OR 'Enabled: Always'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Wireless Display > Require PIN for pairing
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WirelessDisplay
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WirelessDisplay"
$ValueName = "RequirePinForPairing"
$AllowedValues = @(1, 2)

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.14.1: Ensure 'Require PIN for pairing' is Enabled (First Time or Always)"
Write-Host "=============================================================="

function Get-RequirePinForPairingValue {
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

$CurrentValue = Get-RequirePinForPairingValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
} elseif ($AllowedValues -contains $CurrentValue) {
    Write-Host "Current value is $CurrentValue. Policy is compliant." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Current value is $CurrentValue. Expected: 1 (First Time) or 2 (Always)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
