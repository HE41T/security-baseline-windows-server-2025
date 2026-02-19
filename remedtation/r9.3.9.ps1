# ==============================================================
# CIS Check: 9.3.9 (L1) - Remediation Script
# Description: Ensure 'Windows Firewall: Public: Logging: Log successful connections' is set to 'Yes' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 9.3.9: FW Public: Log Success"
Write-Host "=============================================================="


try {
    # 1. Set Active Setting via Cmdlet (Note: Param is LogAllowed)
    Set-NetFirewallProfile -Profile Public -LogAllowed True -ErrorAction SilentlyContinue
    
    # 2. Set Policy Registry
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging"
    $RegName = "LogAllowedConnections"
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