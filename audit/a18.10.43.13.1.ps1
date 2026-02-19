# ==============================================================
# CIS Check: 18.10.43.13.1 (L1) - Audit Script
# Description: Ensure 'Scan excluded files and directories during quick scans' is set to 'Enabled: 1'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan\QuickScanIncludeExclusions
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$ValueName = "QuickScanIncludeExclusions"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.13.1: Check Quick Scan Include Exclusions"
Write-Host "=============================================================="

function Get-QuickScanExclusionValue {
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

$CurrentValue = Get-QuickScanExclusionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Enabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }