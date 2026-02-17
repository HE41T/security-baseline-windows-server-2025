# ==============================================================
# CIS Check: 19.5.1.1 (L1) - Audit Script
# Description: Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled' (Automated)
# Verification: Export USER_RIGHTS via secedit and look for the pattern: Turn off toast notifications on
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$ValueName = "NoToastApplicationNotificationOnLockScreen"
$DesiredValue = 1

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 19.5.1.1: Verify toast notifications on the lock screen are disabled"
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
        try {
            $Path = Join-Path "HKU:\$Sid" $SubKey
            if (Test-Path $Path) {
                $Value = Get-ItemPropertyValue -Path $Path -Name $ValueName -ErrorAction SilentlyContinue
                if ($Value -eq $DesiredValue) {
                    Write-Host "SID ${Sid}: Compliant ($ValueName = $Value)" -ForegroundColor Green
                } else {
                    Write-Host "SID ${Sid}: Non-compliant ($ValueName = $Value)" -ForegroundColor Red
                    $Status = "NON-COMPLIANT"
                }
            } else {
                Write-Host "SID ${Sid}: Policy path not found (Non-compliant)." -ForegroundColor Red
                $Status = "NON-COMPLIANT"
            }
        } catch {
            Write-Host "SID ${Sid}: Audit failure ($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
