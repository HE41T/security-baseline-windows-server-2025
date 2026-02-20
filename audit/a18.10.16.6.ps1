# ==============================================================
# CIS Check: 18.10.16.6 (L1) - Audit Script
# Description: Ensure 'Limit Diagnostic Log Collection' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Limit Diagnostic Log Collection
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\LimitDiagnosticLogCollection
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$ValueName = "LimitDiagnosticLogCollection"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.16.6: Ensure 'Limit Diagnostic Log Collection' is Enabled"
Write-Host "=============================================================="

function Get-LimitDiagnosticLogCollectionValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 0
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-LimitDiagnosticLogCollectionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($Current