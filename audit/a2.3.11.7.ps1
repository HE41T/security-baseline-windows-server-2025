# ==============================================================
# CIS Check: 2.3.11.7 (L1) - Audit Script
# Description: LAN Manager authentication level
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "5"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.3.11.7: LAN Manager authentication level"
Write-Host "=============================================================="


try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $RegName = "LmCompatibilityLevel"
    $Expected = 5

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
