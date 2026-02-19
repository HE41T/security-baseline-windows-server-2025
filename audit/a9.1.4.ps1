# ==============================================================
# CIS Check: 9.1.4 (L1) - Audit Script
# Description: Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\\System32\\logfiles\\firewall\\domainfw.log' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "%SystemRoot%\System32\logfiles\firewall\domainfw.log"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.1.4: FW Domain: Log Name"
Write-Host "=============================================================="


try {
    $Profile = "Domain"
    $Prop = "LogFileName"
    $Exp = "%SystemRoot%\System32\logfiles\firewall\domainfw.log"
    
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
