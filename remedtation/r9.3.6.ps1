# ==============================================================
# CIS Check: 9.3.6 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Logging: Name' is set to '%SystemRoot%\\System32\\logfiles\\firewall\\publicfw.log' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.6: FW Public: Log Name"
Write-Host "=============================================================="



try {
    $Profile = "Public"
    Set-NetFirewallProfile -Profile $Profile -LogFileName "%SystemRoot%\System32\logfiles\firewall\publicfw.log"
    $Msg = "Set Firewall $Profile LogFileName to %SystemRoot%\System32\logfiles\firewall\publicfw.log"
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
