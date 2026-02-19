# ==============================================================
# CIS Check: 18.10.57.3.9.5 (L1) - Audit Script
# Description: Ensure 'Set client connection encryption level' is set to 'Enabled: High Level'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\MinEncryptionLevel
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 3
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "MinEncryptionLevel"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.57.3.9.5: Check RDP Encryption Level (High)"
Write-Host "=============================================================="

function Get-MinEncryptionValue {
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

$CurrentValue = Get-MinEncryptionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - High Level 128-bit)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Encryption level is NOT set to High!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }