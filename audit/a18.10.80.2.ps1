# ==============================================================
# CIS Check: 18.10.80.2 (L1) - Audit Script
# Description: Ensure 'Allow Windows Ink Workspace' is set to 'Enabled: On, but disallow access above lock' OR 'Enabled: Disabled' (Automated)
# Verification: Export USER_RIGHTS via secedit and look for the pattern: Allow Windows Ink Workspace
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
$ValueName = "AllowWindowsInkWorkspace"
$AllowedValues = @(0, 1)

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.80.2: Ensure 'Allow Windows Ink Workspace' is restricted"
Write-Host "=============================================================="

$Status = "NON-COMPLIANT"
try {
    if (Test-Path -Path $RegPath) {
        $CurrentValue = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction SilentlyContinue
        if ($null -ne $CurrentValue -and $AllowedValues -contains $CurrentValue) {
            Write-Host "Current value of '$ValueName' is $CurrentValue. Compliant." -ForegroundColor Green
            $Status = "COMPLIANT"
        } else {
            Write-Host "Value '$ValueName' is set to '$CurrentValue'. Non-compliant." -ForegroundColor Red
        }
    } else {
        Write-Host "Registry path '$RegPath' was not found (Disabled/None)." -ForegroundColor Red
    }
} catch {
    Write-Host "[!] Failed to check registry: $_" -ForegroundColor Yellow
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
