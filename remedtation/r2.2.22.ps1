# ==============================================================
# CIS Check: 2.2.22 (L1) - Remediation Script
# Description: Ensure 'Deny access to this computer from the network' to include 'Guests, Local account and member of Administrators group' (MS only) (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.22: Deny access to this computer from the network"
Write-Host "Required Values: Guests (*S-1-5-32-546), Local account and member of Administrators group (*S-1-5-113)"
Write-Host "=============================================================="


# Required SIDs: Guests (*S-1-5-32-546), Local account and member of Administrators group (*S-1-5-113)
$Privilege = "SeDenyNetworkLogonRight"
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