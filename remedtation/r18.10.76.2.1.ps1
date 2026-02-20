# ==============================================================
# CIS Check: 18.10.76.2.1 (L1) - Remediation Script
# Description: Set SmartScreen to 'Enabled: Warn and prevent bypass'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_smartscreen.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Setting SmartScreen to Warn and Prevent Bypass"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "Remediation started: $Date"

try {
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Set EnableSmartScreen to 1 (Enabled)
    Set-ItemProperty -Path $RegPath -Name "EnableSmartScreen" -Value 1 -Type DWord -Force
    # Set ShellSmartScreenLevel to Block (Warn and prevent bypass)
    Set-ItemProperty -Path $RegPath -Name "ShellSmartScreenLevel" -Value "Block" -Type String -Force
    
    Write-Host "Success: SmartScreen has been configured to Block bypass." -ForegroundColor Green
    Add-Content -Path $LogFile -Value "Status: COMPLIANT - Set to Enable(1) and Block"
    $ExitCode = 0
} catch {
    Write-Host "Error: Failed to set registry values. $_" -ForegroundColor Red
    Add-Content -Path $LogFile -Value "Status: FAILED - $_"
    $ExitCode = 1
}

Write-Host "=============================================================="
exit $ExitCode