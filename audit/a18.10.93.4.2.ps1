# ==============================================================
# CIS Check: 18.10.93.4.2 (L1) - Audit Script
# Description: Ensure 'Select when Preview Builds and Feature Updates are received' is set to 'Enabled: 180 or more days' (Automated)
# Verification: Export USER_RIGHTS via secedit and look for the pattern: 180 or more days
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\WindowsUpdate"
$DeferValueName = "DeferFeatureUpdates"
$PeriodValueName = "DeferFeatureUpdatesPeriodInDays"
$DesiredDefer = 1
$DesiredDays = 180

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.4.2: Verify Preview builds and Feature updates are deferred 180+ days"
Write-Host "=============================================================="

$Status = "COMPLIANT"
$UserSids = Get-ChildItem HKU: | Where-Object {
    $n = $_.Name
    ([regex]::IsMatch($n, 'HKEY_USERS\\S-1-5-') -and -not [regex]::IsMatch($n, '_Classes$'))
} | ForEach-Object {
    Split-Path -Path $_.Name -Leaf
} | Sort-Object -Unique

if (-not $UserSids) {
    Write-Host "No user hives found to audit." -ForegroundColor Yellow
} else {
    foreach ($Sid in $UserSids) {
        $Path = Join-Path "HKU:\$Sid" $SubKey
        if (Test-Path $Path) {
            $Defer = Get-ItemPropertyValue -Path $Path -Name $DeferValueName -ErrorAction SilentlyContinue
            $Days = Get-ItemPropertyValue -Path $Path -Name $PeriodValueName -ErrorAction SilentlyContinue
            
            if ($Defer -eq $DesiredDefer -and $Days -ge $DesiredDays) {
                Write-Host "SID ${Sid}: Compliant ($DeferValueName=$Defer, $PeriodValueName=$Days)" -ForegroundColor Green
            } else {
                Write-Host "SID ${Sid}: Non-compliant ($DeferValueName=$Defer, $PeriodValueName=$Days)" -ForegroundColor Red
                $Status = "NON-COMPLIANT"
            }
        } else {
            Write-Host "SID ${Sid}: Policy path not found (Non-compliant)." -ForegroundColor Red
            $Status = "NON-COMPLIANT"
        }
    }
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
