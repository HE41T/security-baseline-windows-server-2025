# ==============================================================
# CIS Check: 17.5.1 (L1) - Remediation Script
# Description: Audit Account Lockout
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_17_5_1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 17.5.1: Audit Account Lockout"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


$Subcat = "Account Lockout"
try {
    $Params = "/subcategory:`"$Subcat`""
    if ("Disable" -eq "Enable") { $Params += " /success:enable" } else { $Params += " /success:disable" }
    if ("Enable" -eq "Enable") { $Params += " /failure:enable" } else { $Params += " /failure:disable" }
    
    Start-Process "auditpol.exe" -ArgumentList "/set $Params" -NoNewWindow -Wait
    
    $Msg = "Set audit policy for $Subcat"
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
