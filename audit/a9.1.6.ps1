# ==============================================================
# CIS Check: 9.1.6 (L1) - Audit Script
# Description: FW Domain: Log Dropped
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "True"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.1.6: FW Domain: Log Dropped"
Write-Host "=============================================================="


try {
    $Profile = "Domain"
    $Prop = "LogDroppedPackets"
    $Exp = "True"
    
    $Curr = Get-NetFirewallProfile -Profile $Profile | Select-Object -ExpandProperty $Prop
    
    if ("$Curr" -eq $Exp) {
        Write-Host "$Profile $Prop is $Curr (Correct)" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "$Profile $Prop is $Curr (Expected: $Exp)" -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }
} catch {
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
