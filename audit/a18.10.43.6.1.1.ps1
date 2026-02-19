# ==============================================================
# CIS Check: 18.10.43.6.1.1 (L1) - Audit Script
# Description: Ensure 'Configure Attack Surface Reduction rules' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus > Microsoft Defender Exploit Guard > Attack Surface Reduction > Configure Attack Surface Reduction rules
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ExploitGuard_ASR_Rules
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
$ValueName = "ExploitGuard_ASR_Rules"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.6.1.1: Ensure ASR Rules are Enabled"
Write-Host "=============================================================="

function Get-ASRPolicyState {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }

        # ตรวจสอบว่ามีค่า ExploitGuard_ASR_Rules ถูกกำหนดไว้หรือไม่
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return $Value
    } catch {
        return $null
    }
}

$CurrentState = Get-ASRPolicyState

if ($null -eq $CurrentState) {
    Write-Host "[!] ASR Rules policy is NOT configured or missing." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
else {
    Write-Host "ASR Rules policy is Enabled." -ForegroundColor Green
    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }