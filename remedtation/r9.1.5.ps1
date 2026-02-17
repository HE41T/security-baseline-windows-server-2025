# ==============================================================
# CIS Check: 9.1.5 (L1) - Remediation Script
# Description: FW Domain: Log Size
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_9_1_5.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.5: FW Domain: Log Size"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


try {
    $Profile = "Domain"
    Set-NetFirewallProfile -Profile $Profile -LogMaxSizeKilobytes "16384"
    $Msg = "Set Firewall $Profile LogMaxSizeKilobytes to 16384"
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
