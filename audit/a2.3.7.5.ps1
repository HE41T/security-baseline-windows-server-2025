# ==============================================================
# CIS Check: 2.3.7.5 (L1) - Audit Script
# Description: Interactive logon: Message title
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "Enabled"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.7.5: Interactive logon: Message title"
Write-Host "=============================================================="


$Val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeCaption" -ErrorAction SilentlyContinue
if ($Val) { Write-Host "Value set." -ForegroundColor Green; $Status="COMPLIANT" } else { Write-Host "Empty" -ForegroundColor Red; $Status="NON-COMPLIANT" }

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
