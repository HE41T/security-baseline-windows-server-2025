# ==============================================================
# CIS Check: 9.1.4 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Domain: Settings: Display a notification' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.4: FW Domain: Display a notification"
Write-Host "=============================================================="

try {
    # 1. Set Active Setting via Cmdlet (For immediate effect)
    Set-NetFirewallProfile -Profile Domain -NotifyOnListen False -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry (For Nessus/CIS Compliance)
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
    $RegName = "DisableNotifications"
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
Write-Host "Remediation Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") {
    exit 0
} else {
    exit 1
}