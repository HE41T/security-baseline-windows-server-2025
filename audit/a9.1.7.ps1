# ==============================================================
# CIS Check: 9.1.7 (L1) - Audit Script
# Description: Ensure 'Windows Firewall: Domain: Logging: Log successful connections' is set to 'Yes' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 9.1.7: FW Domain: Log Successful Connections"
Write-Host "=============================================================="

try {
    # Nessus/CIS checks this specific Policy Registry Path
    $RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging"
    $RegName = "LogSuccessfulConnections"
    $Exp = "1" # 1 = Yes

    $Val = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    
    if ($Val) {
        $Curr = $Val.$RegName.ToString()
    } else {
        $Curr = "Not Set"
    }
    
    if ($Curr -eq $Exp) {
        Write-Host "Registry $RegName is $Curr (Correct)" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Registry $RegName is $Curr (Expected: $Exp)" -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }

} catch {
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }