# ==============================================================
# CIS Check: 18.10.43.10.1 (L1) - Audit Script
# Description: Ensure 'Configure real-time protection and Security Intelligence Updates during OOBE' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus > Real-Time Protection > Configure real-time protection and Security Intelligence Updates during OOBE
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection\OobeEnableRtpAndSigUpdate
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection"
$ValueName = "OobeEnableRtpAndSigUpdate"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.10.1: Ensure Defender Protection during OOBE is Enabled"
Write-Host "=============================================================="

function Get-OOBEProtectionValue {
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

$CurrentValue = Get-OOBEProtectionValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current setting or value does not exist." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Enabled ($CurrentValue)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue (Enabled)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }