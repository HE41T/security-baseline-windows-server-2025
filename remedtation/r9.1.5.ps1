# ==============================================================
# CIS Check: 9.1.5 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Domain: Logging: Name' is set to '%SystemRoot%\System32\logfiles\firewall\domainfw.log' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.1.5: FW Domain: Logging Name"
Write-Host "=============================================================="

try {
    # 1. Set Active Setting via Cmdlet (For immediate effect)
    Set-NetFirewallProfile -Profile Domain -LogFileName "%SystemRoot%\System32\logfiles\firewall\domainfw.log" -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry (For Nessus/CIS Compliance)
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $RegName = "LogFilePath"
    $Value = "%SystemRoot%\System32\logfiles\firewall\domainfw.log"
    
    if (!(Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $Value -Type String -Force
    
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