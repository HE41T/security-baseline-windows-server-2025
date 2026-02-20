# ==============================================================
# CIS Check: 18.10.43.13.5 (L1) - Audit Script
# Description: Ensure 'Turn on e-mail scanning' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan\DisableEmailScanning
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan"
$ValueName = "DisableEmailScanning"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.13.5: Check E-mail Scanning Status"
Write-Host "=============================================================="

function Get-EmailScanValue {
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

$CurrentValue = Get-EmailScanValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - E-mail Scanning is Enabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). E-mail scanning is DISABLED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }