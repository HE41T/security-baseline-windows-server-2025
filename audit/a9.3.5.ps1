# ==============================================================
# CIS Check: 9.3.5 (L1) - Audit Script
# Description: Ensure 'Windows Firewall: Public: Settings: Apply local connection security rules' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "False"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.3.5: FW Public: Apply local ipsec"
Write-Host "=============================================================="


try {
    $Profile = "Public"
    $Prop = "AllowLocalIPsecRules"
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
