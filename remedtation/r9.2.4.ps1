# ==============================================================
# CIS Check: 9.2.4 (L1) - Remediation Script
# Description: FW Private: Log Name
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_9_2_4.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.2.4: FW Private: Log Name"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


try {
    $Profile = "Private"
    Set-NetFirewallProfile -Profile $Profile -LogFileName "%SystemRoot%\System32\logfiles\firewall\privatefw.log"
    $Msg = "Set Firewall $Profile LogFileName to %SystemRoot%\System32\logfiles\firewall\privatefw.log"
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
