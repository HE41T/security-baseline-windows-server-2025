# ==============================================================
# CIS Check: 2.3.1.3 (L1) - Remediation Script
# Description: Configure 'Accounts: Rename administrator account' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.1.3: Rename administrator account"
Write-Host "=============================================================="



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
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
