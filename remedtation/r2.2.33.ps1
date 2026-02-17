# ==============================================================
# CIS Check: 2.2.33 (L1) - Remediation Script
# Description: Impersonate a client after authentication
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_2_33.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.33: Impersonate a client after authentication"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


$Privilege = "SeImpersonatePrivilege"
$Sids = "*S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6,*S-1-5-32-568"
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
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} catch {
    $Msg = "Error: $_"
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
