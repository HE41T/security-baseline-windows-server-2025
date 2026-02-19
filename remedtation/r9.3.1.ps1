# ==============================================================
# CIS Check: 9.3.1 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Firewall state' is set to 'On (recommended)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.1: FW Public: State"
Write-Host "=============================================================="



try {
    $Profile = "Public"
    Set-NetFirewallProfile -Profile $Profile -Enabled "True"
    $Msg = "Set Firewall $Profile Enabled to True"
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
