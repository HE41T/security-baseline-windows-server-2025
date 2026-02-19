# ==============================================================
# CIS Check: 2.2.31 (L1) - Remediation Script
# Description: Ensure 'Generate security audits' is set to 'LOCAL SERVICE, NETWORK SERVICE' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.31: Generate security audits"
Write-Host "=============================================================="



$Privilege = "SeAuditPrivilege"
$Sids = "*S-1-5-19,*S-1-5-20"
$InfFile = "C:\Windows\Temp\remediate_ur.inf"

try {
    $Content = @"
[Unicode]
Unicode=yes
[Privilege Rights]
$Privilege = $Sids
[Version]
signature="`$CHICAGO`$"
Revision=1
"@
    Set-Content -Path $InfFile -Value $Content -Encoding Unicode
    
    # Apply
    Secedit /configure /db secedit.sdb /cfg $InfFile /areas USER_RIGHTS
    
    $Msg = "Applied User Right: $Privilege = $Sids"
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
} catch {
    $Msg = "Error: $_"
    Write-Host $Msg -ForegroundColor Red
        $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
