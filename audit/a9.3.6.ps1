# ==============================================================
# CIS Check: 9.3.6 (L1) - Audit Script
# Description: FW Public: Log Name
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "%SystemRoot%\System32\logfiles\firewall\publicfw.log"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.3.6: FW Public: Log Name"
Write-Host "=============================================================="


try {
    $Profile = "Public"
    $Prop = "LogFileName"
    $Exp = "%SystemRoot%\System32\logfiles\firewall\publicfw.log"
    
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
