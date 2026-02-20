# ==============================================================
# CIS Check: 18.10.93.4.3 (L1) - Remediation Script
# Description: Set Quality Update Deferral to 0 days
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_wu_quality_deferral.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Setting Quality Update Deferral to 0 days"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "Remediation started: $Date"

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Enable Deferral Policy
    Set-ItemProperty -Path $RegPath -Name "DeferQualityUpdates" -Value 1 -Type DWord -Force
    # Set Period to 0 days (Immediate)
    Set-ItemProperty -Path $RegPath -Name "DeferQualityUpdatesPeriodInDays" -Value 0 -Type DWord -Force
    
    Write-Host "Success: Quality Updates are now set to be received with 0 days deferral." -ForegroundColor Green
    Add-Content -Path $LogFile -Value "Status: COMPLIANT - Deferral set to 0 days"
    $ExitCode = 0
} catch {
    Write-Host "Error: Failed to set registry values. $_" -ForegroundColor Red
    Add-Content -Path $LogFile -Value "Status: FAILED - $_"
    $ExitCode = 1
}

Write-Host "=============================================================="
exit $ExitCode