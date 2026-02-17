# ==============================================================
# CIS Check: 5.2 (L1) - Audit Script
# Description: Print Spooler (MS)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "Enabled"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 5.2: Print Spooler (MS)"
Write-Host "=============================================================="


$Svc = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
if ($Svc.StartType -eq "Disabled") { $Status="COMPLIANT" } else { $Status="NON-COMPLIANT" }
Write-Host "Service Status: $($Svc.StartType)"

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
