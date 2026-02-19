# ==============================================================
# CIS Check: 9.1.4 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\\System32\\logfiles\\firewall\\domainfw.log' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.4: FW Domain: Log Name"
Write-Host "=============================================================="



try {
    $Profile = "Domain"
    Set-NetFirewallProfile -Profile $Profile -LogFileName "%SystemRoot%\System32\logfiles\firewall\domainfw.log"
    $Msg = "Set Firewall $Profile LogFileName to %SystemRoot%\System32\logfiles\firewall\domainfw.log"
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
