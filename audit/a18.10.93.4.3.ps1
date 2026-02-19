# ==============================================================
# CIS Check: 18.10.93.4.3 (L1) - Audit Script
# Description: Ensure 'Select when Quality Updates are received' is set to 'Enabled: 0 days'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.4.3: Check Quality Update Deferral Period"
Write-Host "=============================================================="

function Get-QualityUpdateDeferral {
    if (-not (Test-Path $RegPath)) { return $null }
    
    $DeferStatus = Get-ItemPropertyValue -Path $RegPath -Name "DeferQualityUpdates" -ErrorAction SilentlyContinue
    $DeferDays = Get-ItemPropertyValue -Path $RegPath -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    
    return @{ Status = $DeferStatus; Days = $DeferDays }
}

$Current = Get-QualityUpdateDeferral

if ($null -eq $Current.Status -or $null -eq $Current.Days) {
    Write-Host "[!] Quality Update Deferral is NOT configured via GPO." -ForegroundColor Yellow
    $OverallStatus = "NON-COMPLIANT"
}
elseif ($Current.Status -eq 1 -and $Current.Days -eq 0) {
    Write-Host "Value is Compliant (Deferral: Enabled, Days: 0)." -ForegroundColor Green
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