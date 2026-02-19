# ==============================================================
# CIS Check: 18.10.43.13.4 (L1) - Audit Script
# Description: Ensure 'Trigger a quick scan after X days without any scans' is set to 'Enabled: 7'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan\DaysUntilAggressiveCatchupQuickScan
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 7
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$ValueName = "DaysUntilAggressiveCatchupQuickScan"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.13.4: Check Aggressive Quick Scan Catchup (7 Days)"
Write-Host "=============================================================="

function Get-AggressiveScanValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return $null
    }
}

$CurrentValue = Get-AggressiveScanValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured. Default is Disabled (No aggressive scans)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue Days)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue Days). Expected: $DesiredValue Days." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }