# ==============================================================
# CIS Check: 2.3.7.4 (L1) - Remediation Script
# Description: Interactive logon: Message text
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_3_7_4.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.7.4: Interactive logon: Message text"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


# Manual check usually required for text content.
Write-Host "Please set LegalNoticeText manually in Registry." -ForegroundColor Yellow
$Status = "MANUAL"

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
