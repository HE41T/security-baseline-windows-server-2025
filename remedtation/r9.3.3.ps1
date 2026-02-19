# ==============================================================
# CIS Check: 9.3.3 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Settings: Display a notification' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.3: FW Public: Notify"
Write-Host "=============================================================="



try {
    $Profile = "Public"
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
