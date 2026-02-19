# ==============================================================
# CIS Check: 2.3.7.5 (L1) - Audit Script
# Description: Interactive logon: Message title for users attempting to log on
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "Notice and Consent Banner"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegName = "LegalNoticeCaption"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.7.5: Interactive logon: Message title"
Write-Host "=============================================================="

try {
    $Item = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
    if ($Item -and $Item.PSObject.Properties[$RegName]) {
        $CurrentValue = $Item.$RegName
    } else {
        $CurrentValue = $null
    }

    Write-Host "Current Setting: '$CurrentValue'"
    Write-Host "Desired Setting: '$DesiredValue'"

    if ($CurrentValue -eq $DesiredValue) {
        Write-Host "Status: COMPLIANT" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Status: NON-COMPLIANT" -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }
} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }