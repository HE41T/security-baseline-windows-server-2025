# ==============================================================
# CIS Check: 18.10.29.2 (L1) - Audit Script
# Description: Ensure 'Do not apply the Mark of the Web tag to files copied from insecure sources' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > File Explorer > Do not apply the Mark of the Web tag to files copied from insecure sources
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileContentComplementaryHandlers\DoNotApplyMotwToFilesFromInsecureSources
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileContentComplementaryHandlers"
$ValueName = "DoNotApplyMotwToFilesFromInsecureSources"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.29.2: Ensure MotW Tagging is NOT Disabled"
Write-Host "=============================================================="

function Get-MotwPolicyValue {
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

$CurrentValue = Get-MotwPolicyValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Disabled ($CurrentValue) - Correct Behavior." -ForegroundColor Green
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