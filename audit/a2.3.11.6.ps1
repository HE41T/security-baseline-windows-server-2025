# ==============================================================
# CIS Check: 2.3.11.6 (L1) - Audit Script
# Description: Force logoff when logon hours expire
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "1"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.11.6: Force logoff when logon hours expire"
Write-Host "=============================================================="


try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
    $RegName = "ForceLogoffWhenHourExpire"
    $Expected = 1

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
