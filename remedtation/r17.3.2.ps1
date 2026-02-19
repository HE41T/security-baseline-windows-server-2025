# ==============================================================
# CIS Check: 17.3.2 (L1) - Remediation Script
# Description: Ensure 'Audit Process Creation' is set to include 'Success'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_17_3_2.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 17.3.2: Ensure 'Audit Process Creation' is set to include 'Success'"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

$Subcat = "{0cce922b-69ae-11d9-bed3-505054503030}"

try {
    $Params = "/subcategory:`"$Subcat`" /success:enable"
    
    Start-Process "auditpol.exe" -ArgumentList "/set $Params" -NoNewWindow -Wait
    
    $Msg = "Set audit policy for Audit Process Creation to include Success"
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
