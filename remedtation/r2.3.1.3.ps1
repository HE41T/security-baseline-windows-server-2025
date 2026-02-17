# ==============================================================
# CIS Check: 2.3.1.3 (L1) - Remediation Script
# Description: Rename administrator account
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_3_1_3.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.1.3: Rename administrator account"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


try {
    $User = Get-LocalUser | Where-Object { $_.SID -like "S-1-5-21-*-500" }
    if ($User) {
        Rename-LocalUser -Name $User.Name -NewName "Administrator_REN"
        $Status = "COMPLIANT"
    }
} catch { $Status = "NON-COMPLIANT" }

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
