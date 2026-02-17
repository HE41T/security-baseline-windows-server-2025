# ==============================================================
# CIS Check: 19.7.5.1 (L1) - Audit Script
# Description: Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled' (Automated)
# Verification: Iterate through HKU user hives to confirm the setting
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubPath = "Software\Microsoft\Windows\CurrentVersion\Policies\Attachments"
$ValueName = "SaveZoneInformation"
$DesiredValue = 2

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.7.5.1: Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled' (Automated)"
Write-Host "=============================================================="

$Status = "COMPLIANT"
$NonCompliant = @()
$Sids = Get-ChildItem HKU:\ | Where-Object { $_.PSChildName -match '^S-1-5-21-' }
if (-not $Sids) {
    Write-Host "No user hives were detected under HKU:\" -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
else {
    foreach ($Sid in $Sids) {
        $RegistryPath = Join-Path "HKU:\$($Sid.PSChildName)" $SubPath
        if (-not (Test-Path -Path $RegistryPath)) {
            Write-Host "[!] Missing key for $($Sid.PSChildName): $RegistryPath" -ForegroundColor Yellow
            $NonCompliant += "$($Sid.PSChildName) (missing key)"
            $Status = "NON-COMPLIANT"
            continue
        }
        try {
            $Value = Get-ItemPropertyValue -Path $RegistryPath -Name $ValueName -ErrorAction Stop
        } catch {
            Write-Host "[!] Could not read $ValueName for $($Sid.PSChildName)." -ForegroundColor Yellow
            $NonCompliant += "$($Sid.PSChildName) (missing value)"
            $Status = "NON-COMPLIANT"
            continue
        }
        if ([int]$Value -ne $DesiredValue) {
            Write-Host "[!] $($Sid.PSChildName): Current value is $Value, expected $DesiredValue." -ForegroundColor Red
            $NonCompliant += "$($Sid.PSChildName) (value $Value)"
            $Status = "NON-COMPLIANT"
        } else {
            Write-Host "$($Sid.PSChildName): Value is $Value." -ForegroundColor Green
        }
    }
}

if ($NonCompliant.Count -gt 0) {
    Write-Host "Non-compliant SIDs: $($NonCompliant -join ', ')" -ForegroundColor Red
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
