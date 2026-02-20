# ==============================================================
# CIS Check: 18.10.57.3.9.2 (L1) - Audit Script
# Description: Ensure 'Require secure RPC communication' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\fEncryptRPCTraffic
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "fEncryptRPCTraffic"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.57.3.9.2: Check Secure RPC Communication"
Write-Host "=============================================================="

function Get-SecureRPCValue {
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

$CurrentValue = Get-SecureRPCValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default might allow unsecure RPC)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Secure RPC is Required)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Unsecure RPC is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }