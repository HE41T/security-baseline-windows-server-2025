# ==============================================================
# CIS Check: 9.3.8 (L1) - Remediation Script
# Description: FW Public: Log Dropped Packets (Registry & Cmdlet)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_9_3_8.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.8: FW Public: Log Dropped Packets"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

try {
    # 1. Set Active Setting via Cmdlet
    Set-NetFirewallProfile -Profile Public -LogBlocked True -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $RegName = "LogDroppedPackets"
    $Value = 1
    
    if (!(Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $Value -Type DWord -Force
    
    $Msg = "Set Registry $RegName to $Value (Enabled)"
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