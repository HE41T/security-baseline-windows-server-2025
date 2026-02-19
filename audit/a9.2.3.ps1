# ==============================================================
# CIS Check: 9.2.3 (L1) - Audit Script
# Description: Ensure 'Windows Firewall: Private: Settings: Display a notification' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "False"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.2.3: FW Private: Notify"
Write-Host "=============================================================="


try {
    $Profile = "Private"
    $Prop = "NotifyOnListen"
    $Exp = "False"
    
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
