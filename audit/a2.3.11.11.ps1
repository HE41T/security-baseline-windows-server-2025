# ==============================================================
# CIS Check: 2.3.11.11 (L1) - Audit Script
# Description: Min session security for NTLM SSP based servers
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "537395200"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.11.11: Min session security for NTLM SSP based servers"
Write-Host "=============================================================="


try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
    $RegName = "NtlmMinServerSec"
    $Expected = 537395200

    $Item = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    
    if ($Item) {
        $CurrentValue = $Item.$RegName
    } else {
        $CurrentValue = $null
    }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error: $_" -ForegroundColor Red
}

if ($CurrentValue -eq $Expected) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Value is incorrect ($($CurrentValue)). Expected: $Expected" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
