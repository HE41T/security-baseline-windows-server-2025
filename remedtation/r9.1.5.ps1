# ==============================================================
# CIS Check: 9.1.5 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Domain: Logging: Size limit (KB)' is set to '16,384 KB or greater' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.5: FW Domain: Log Size"
Write-Host "=============================================================="



try {
    $Profile = "Domain"
    Set-NetFirewallProfile -Profile $Profile -LogMaxSizeKilobytes "16384"
    $Msg = "Set Firewall $Profile LogMaxSizeKilobytes to 16384"
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
