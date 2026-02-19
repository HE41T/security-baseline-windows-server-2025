# ==============================================================
# CIS Check: 17.9.1 (L1) - Remediation Script
# Description: Ensure 'Audit IPsec Driver' is set to 'Success and Failure' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 17.9.1: Audit IPsec Driver"
Write-Host "=============================================================="



$Subcat = "IPsec Driver"
try {
    $Params = "/subcategory:`"$Subcat`""
    if ("Enable" -eq "Enable") { $Params += " /success:enable" } else { $Params += " /success:disable" }
    if ("Enable" -eq "Enable") { $Params += " /failure:enable" } else { $Params += " /failure:disable" }
    
    Start-Process "auditpol.exe" -ArgumentList "/set $Params" -NoNewWindow -Wait
    
    $Msg = "Set audit policy for $Subcat"
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
