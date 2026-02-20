# ==============================================================
# CIS Check: 9.3.5 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Settings: Apply local firewall rules' is set to 'No' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.5: FW Public: Apply local firewall rules"
Write-Host "=============================================================="

try {
    # 1. Set Active Setting via Cmdlet (For immediate effect)
    Set-NetFirewallProfile -Profile Public -AllowLocalFirewallRules False -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry (For Nessus/CIS Compliance)
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
    $RegName = "AllowLocalPolicyMerge"
    $Value = 0
    
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