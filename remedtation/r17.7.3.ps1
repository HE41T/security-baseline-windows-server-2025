# ==============================================================
# CIS Check: 17.7.3 (L1) - Remediation Script
# Description: Audit Authorization Policy Change
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_17_7_3.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 17.7.3: Audit Authorization Policy Change"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


$Subcat = "Authorization Policy Change"
try {
    $Params = "/subcategory:`"$Subcat`""
    if ("Enable" -eq "Enable") { $Params += " /success:enable" } else { $Params += " /success:disable" }
    if ("Disable" -eq "Enable") { $Params += " /failure:enable" } else { $Params += " /failure:disable" }
    
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
