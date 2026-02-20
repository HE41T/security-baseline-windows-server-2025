# ==============================================================
# CIS Check: 18.10.57.3.3.3 (L1) - Audit Script
# Description: Ensure 'Do not allow drive redirection' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\fDisableCdm
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "fDisableCdm"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.57.3.3.3: Check RDP Drive Redirection Restriction"
Write-Host "=============================================================="

function Get-DriveRedirectionValue {
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

$CurrentValue = Get-DriveRedirectionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Drive redirection might be allowed)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Drive Redirection is DISABLED)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Drive redirection is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }