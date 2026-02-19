# ==============================================================
# CIS Check: 9.1.3 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Domain: Settings: Display a notification' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.3: FW Domain: Notify"
Write-Host "=============================================================="



try {
    $Profile = "Domain"
    Set-NetFirewallProfile -Profile $Profile -NotifyOnListen "False"
    $Msg = "Set Firewall $Profile NotifyOnListen to False"
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
} catch {
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
