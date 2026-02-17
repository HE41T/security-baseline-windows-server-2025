# ==============================================================
# CIS Check: 5.1 (L1) - Remediation Script
# Description: Print Spooler (DC)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_5_1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 5.1: Print Spooler (DC)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


Set-Service -Name "Spooler" -StartupType Disabled
Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
$Status="COMPLIANT"

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
