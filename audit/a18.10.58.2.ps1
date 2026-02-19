# ==============================================================
# CIS Check: 18.10.58.2 (L1) - Audit Script
# Description: Ensure 'Turn on Basic feed authentication over HTTP' is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds\AllowBasicAuthInClear
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds"
$ValueName = "AllowBasicAuthInClear"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.58.2: Check RSS Basic Auth over HTTP Status"
Write-Host "=============================================================="

function Get-RSSBasicAuthValue {
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

$CurrentValue = Get-RSSBasicAuthValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Basic Auth over HTTP is Disabled)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Basic Auth over HTTP is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }