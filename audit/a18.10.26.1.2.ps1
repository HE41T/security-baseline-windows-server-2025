# ==============================================================
# CIS Check: 18.10.26.1.2 (L1) - Audit Script
# Description: Ensure 'Application: Specify the maximum log file size (KB)' is set to 'Enabled: 32,768 or greater'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Event Log Service > Application > Specify the maximum log file size (KB)
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application\MaxSize
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$MinimumValue = 32768
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$ValueName = "MaxSize"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.26.1.2: Ensure 'Application Log MaxSize' is >= $MinimumValue KB"
Write-Host "=============================================================="

function Get-EventLogMaxSizeValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        Write-Host "[!] Unable to read registry value: $_" -ForegroundColor Yellow
        return $null
    }
}

$CurrentValue = Get-EventLogMaxSizeValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -ge $MinimumValue) {
    Write-Host "Value is Compliant ($CurrentValue KB)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue KB). Expected: >= $MinimumValue KB." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }