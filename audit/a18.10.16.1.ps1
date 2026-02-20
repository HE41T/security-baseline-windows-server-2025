# ==============================================================
# CIS Check: 18.10.16.1 (L1) - Audit Script
# Description: Ensure 'Allow Diagnostic Data' is set to 'Enabled: Diagnostic data off' or 'Enabled: Send required diagnostic data'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Allow Diagnostic Data
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$ValueName = "AllowTelemetry"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.16.1: Ensure 'Allow Diagnostic Data' is 0 (Off) or 1 (Required)"
Write-Host "=============================================================="

function Get-AllowTelemetryValue {
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

$CurrentValue = Get-AllowTelemetryValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq 0) {
    Write-Host "Value is Enabled: Diagnostic data off ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
elseif ($CurrentValue -eq 1) {
    Write-Host "Value is Enabled: Send required diagnostic data ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: 0 (Off) or 1 (Required)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }