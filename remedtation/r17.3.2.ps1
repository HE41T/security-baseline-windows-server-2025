# ==============================================================
# CIS Check: 17.3.2 (L1) - Remediation Script
# Description: Ensure 'Audit Process Creation' is set to include 'Success'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 17.3.2: Ensure 'Audit Process Creation' is set to include 'Success'"
Write-Host "=============================================================="


$Subcat = "{0cce922b-69ae-11d9-bed3-505054503030}"

try {
    $Params = "/subcategory:`"$Subcat`" /success:enable"
    
    Start-Process "auditpol.exe" -ArgumentList "/set $Params" -NoNewWindow -Wait
    
    $Msg = "Set audit policy for Audit Process Creation to include Success"
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
