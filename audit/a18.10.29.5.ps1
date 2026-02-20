# ==============================================================
# CIS Check: 18.10.29.5 (L1) - Audit Script
# Description: Ensure 'Turn off shell protocol protected mode' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > File Explorer > Turn off shell protocol protected mode
# Registry Path: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\PreXPSP2ShellProtocolBehavior
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$ValueName = "PreXPSP2ShellProtocolBehavior"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.29.5: Ensure Shell Protocol Protected Mode is NOT Disabled"
Write-Host "=============================================================="

function Get-ShellProtoPolicyValue {
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

$CurrentValue = Get-ShellProtoPolicyValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Disabled ($CurrentValue) - Protected Mode remains Active." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Disabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }