# ==============================================================
# CIS Check: 2.2.47 (L1) - Remediation Script
# Description: Ensure 'Shut down the system' is set to 'Administrators' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.47: Shut down the system"
Write-Host "=============================================================="



$Privilege = "SeShutdownPrivilege"
$Sids = "*S-1-5-32-544"
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
