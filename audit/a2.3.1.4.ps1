# ==============================================================
# CIS Check: 2.3.1.4 (L1) - Audit Script
# Description: Rename guest account
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "Enabled"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.1.4: Rename guest account"
Write-Host "=============================================================="


try {
    $User = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-501" }
    if ($User.Name -ne "Administrator" -and $User.Name -ne "Guest") {
        Write-Host "Account Renamed: $($User.Name)" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Account is still default ($($User.Name))" -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }
} catch { $Status = "NON-COMPLIANT" }

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
