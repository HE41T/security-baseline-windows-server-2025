# ==============================================================
# CIS Check: 18.10.76.2.1 (L1) - Audit Script
# Description: Ensure 'Configure Windows Defender SmartScreen' is set to 'Enabled: Warn and prevent bypass'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\System
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.76.2.1: Check SmartScreen Configuration"
Write-Host "=============================================================="

function Get-SmartScreenAudit {
    if (-not (Test-Path $RegPath)) { return $null }
    
    $EnableValue = Get-ItemPropertyValue -Path $RegPath -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
    $LevelValue = Get-ItemPropertyValue -Path $RegPath -Name "ShellSmartScreenLevel" -ErrorAction SilentlyContinue
    
    return @{ Enable = $EnableValue; Level = $LevelValue }
}

$Current = Get-SmartScreenAudit

if ($null -eq $Current.Enable -or $null -eq $Current.Level) {
    Write-Host "[!] SmartScreen is NOT configured via GPO." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($Current.Enable -eq 1 -and $Current.Level -eq "Block") {
    Write-Host "Value is Compliant (Enabled: Block/Prevent Bypass)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect (Enable: $($Current.Enable), Level: $($Current.Level))." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }