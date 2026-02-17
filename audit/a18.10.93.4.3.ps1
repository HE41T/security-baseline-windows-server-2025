# ==============================================================
# CIS Check: 18.10.93.4.3 (L1) - Audit Script
# Description: Ensure 'Select when Quality Updates are received' is set to 'Enabled: 0 days' (Automated)
# Verification: Export USER_RIGHTS via secedit and look for the pattern: 0 days
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\WindowsUpdate"
$DeferValueName = "DeferQualityUpdates"
$PeriodValueName = "DeferQualityUpdatesPeriodInDays"
$DesiredDefer = 1
$DesiredDays = 0

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.93.4.3: Verify Quality updates are deferred 0 days"
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
            
            if ($Defer -eq $DesiredDefer -and $Days -eq $DesiredDays) {
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
