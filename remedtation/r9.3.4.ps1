# ==============================================================
# CIS Check: 9.3.4 (L1) - Remediation Script
# Description: FW Public: Apply local rules
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_9_3_4.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.4: FW Public: Apply local rules"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


try {
    $Profile = "Public"
    Set-NetFirewallProfile -Profile $Profile -AllowLocalFirewallRules "False"
    $Msg = "Set Firewall $Profile AllowLocalFirewallRules to False"
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} catch {
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
