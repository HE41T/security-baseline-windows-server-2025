# ==============================================================
# CIS Check: 9.3.2 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Inbound connections' is set to 'Block (default)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.2: FW Public: Inbound"
Write-Host "=============================================================="



try {
    $Profile = "Public"
    Set-NetFirewallProfile -Profile $Profile -DefaultInboundAction "Block"
    $Msg = "Set Firewall $Profile DefaultInboundAction to Block"
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
