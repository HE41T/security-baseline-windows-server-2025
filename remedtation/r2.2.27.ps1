# ==============================================================
# CIS Check: 2.2.27 (L1) - Remediation Script
# Description: Deny log on through Remote Desktop Services
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_2_27.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.27: Deny log on through Remote Desktop Services"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


$Privilege = "SeDenyRemoteInteractiveLogonRight"
$Sids = "*S-1-5-32-546,*S-1-5-113"
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
