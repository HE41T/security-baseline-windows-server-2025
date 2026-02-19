# ==============================================================
# CIS Check: 9.2.6 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Private: Logging: Log dropped packets' is set to 'Yes' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.2.6: FW Private: Log Dropped Packets"
Write-Host "=============================================================="


try {
    # 1. Set Active Setting via Cmdlet
    Set-NetFirewallProfile -Profile Private -LogBlocked True -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging"
    $RegName = "LogDroppedPackets"
    $Value = 1
    
    if (!(Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $Value -Type DWord -Force
    
    $Msg = "Set Registry $RegName to $Value (Enabled)"
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