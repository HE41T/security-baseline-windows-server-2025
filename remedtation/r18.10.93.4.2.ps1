# ==============================================================
# CIS Check: 18.10.93.4.2 (L1) - Remediation Script
# Description: Set Feature Update Deferral to 180 days
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_wu_deferral.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Setting Feature Update Deferral to 180 days"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "Remediation started: $Date"

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Enable Deferral
    Set-ItemProperty -Path $RegPath -Name "DeferFeatureUpdates" -Value 1 -Type DWord -Force
    # Set Period to 180 days
    Set-ItemProperty -Path $RegPath -Name "DeferFeatureUpdatesPeriodInDays" -Value 180 -Type DWord -Force
    
    Write-Host "Success: Feature Updates are now deferred for 180 days." -ForegroundColor Green
    Add-Content -Path $LogFile -Value "Status: COMPLIANT - Deferral enabled for 180 days"
    $ExitCode = 0
} catch {
    Write-Host "Error: Failed to set registry values. $_" -ForegroundColor Red
    Add-Content -Path $LogFile -Value "Status: FAILED - $_"
    $ExitCode = 1
}

Write-Host "=============================================================="
exit $ExitCode