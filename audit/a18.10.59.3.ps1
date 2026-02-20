# ==============================================================
# CIS Check: 18.10.59.3 (L1) - Audit Script
# Description: Ensure 'Allow indexing of encrypted files' is set to 'Disabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search\AllowIndexingEncryptedStoresOrItems
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$ValueName = "AllowIndexingEncryptedStoresOrItems"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.59.3: Check Indexing of Encrypted Files"
Write-Host "=============================================================="

function Get-SearchIndexingValue {
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

$CurrentValue = Get-SearchIndexingValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured via GPO (Default is Disabled)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - Indexing is Blocked)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Indexing of encrypted files is ALLOWED!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }