# ==============================================================
# CIS Check: 18.10.93.4.2 (L1) - Audit Script
# Description: Ensure 'Select when Preview Builds and Feature Updates are received' is set to 'Enabled: 180 or more days'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.4.2: Check Feature Update Deferral Period"
Write-Host "=============================================================="

function Get-FeatureUpdateDeferral {
    if (-not (Test-Path $RegPath)) { return $null }
    
    $DeferStatus = Get-ItemPropertyValue -Path $RegPath -Name "DeferFeatureUpdates" -ErrorAction SilentlyContinue
    $DeferDays = Get-ItemPropertyValue -Path $RegPath -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    
    return @{ Status = $DeferStatus; Days = $DeferDays }
}

$Current = Get-FeatureUpdateDeferral

if ($null -eq $Current.Status -or $null -eq $Current.Days) {
    Write-Host "[!] Feature Update Deferral is NOT configured via GPO." -ForegroundColor Yellow
    $OverallStatus = "NON-COMPLIANT"
}
elseif ($Current.Status -eq 1 -and $Current.Days -ge 180) {
    Write-Host "Value is Compliant (Deferral: Enabled, Days: $($Current.Days))." -ForegroundColor Green
    $OverallStatus = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect (Deferral: $($Current.Status), Days: $($Current.Days))." -ForegroundColor Red
    $OverallStatus = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $OverallStatus"
Write-Host "=============================================================="

if ($OverallStatus -eq "COMPLIANT") { exit 0 } else { exit 1 }