# ==============================================================
# CIS Check: 18.10.16.1 (L1) - Audit Script
# Description: Ensure 'Allow Diagnostic Data' is set to 'Enabled: Diagnostic data off (not recommended)' OR 'Enabled: Send required diagnostic data'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Allow Telemetry
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
$ValueName = "AllowTelemetry"
$AllowedValues = @(0, 1)

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.16.1: Ensure 'Allow Diagnostic Data' is set to a minimal state (0 or 1)"
Write-Host "=============================================================="

function Get-AllowTelemetryValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 3
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Failed reading registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-AllowTelemetryValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($AllowedValues -contains $CurrentValue) {
    Write-Host "Current value is $CurrentValue. Policy is compliant." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Current value is $CurrentValue. Expected: 0 (Diagnostic data off) or 1 (Send required diagnostic data)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
