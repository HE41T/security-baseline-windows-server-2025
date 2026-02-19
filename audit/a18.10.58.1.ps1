# ==============================================================
# CIS Check: 18.10.58.1 (L1) - Audit Script
# Description: Ensure 'Prevent downloading of enclosures' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds\DisableEnclosureDownload
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds"
$ValueName = "DisableEnclosureDownload"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.58.1: Check RSS Feed Enclosure Download Restriction"
Write-Host "=============================================================="

function Get-RSSDisableValue {
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

$CurrentValue = Get-RSSDisableValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Allowed)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Downloading is Blocked)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). RSS downloading is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }