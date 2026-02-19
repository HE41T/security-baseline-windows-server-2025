# ==============================================================
# CIS Check: 18.10.57.2.2 (L1) - Audit Script
# Description: Ensure 'Do not allow passwords to be saved' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\DisablePasswordSaving
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "DisablePasswordSaving"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.57.2.2: Check RDP Password Saving Restriction"
Write-Host "=============================================================="

function Get-RDPPasswordRestriction {
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

$CurrentValue = Get-RDPPasswordRestriction

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Password saving might be allowed)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Password saving is DISABLED)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Password saving is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }