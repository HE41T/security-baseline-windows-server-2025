# ==============================================================
# CIS Check: 18.10.80.2 (L1) - Audit Script
# Description: Ensure 'Allow Windows Ink Workspace' is set correctly
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace\AllowWindowsInkWorkspace
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
$ValueName = "AllowWindowsInkWorkspace"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.80.2: Check Windows Ink Workspace Access"
Write-Host "=============================================================="

function Get-WindowsInkValue {
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

$CurrentValue = Get-WindowsInkValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured (Default might allow access above lock)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq 0 -or $CurrentValue -eq 1) {
    $Mode = if ($CurrentValue -eq 0) { "Disabled" } else { "On, but disallow access above lock" }
    Write-Host "Value is Compliant ($CurrentValue - $Mode)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Access above lock is likely ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }