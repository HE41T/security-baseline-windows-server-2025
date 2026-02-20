# ==============================================================
# CIS Check: 18.10.43.6.1.1 (L1) - Remediation Script
# Description: Ensure 'Configure Attack Surface Reduction rules' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_asr_rules.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
$ValueName = "ExploitGuard_ASR_Rules"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.43.6.1.1: Enabling ASR Rules Policy Structure"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # หมายเหตุ: การตั้งค่านี้เป็นการเปิดโครงสร้างนโยบายให้เป็น Enabled (1)
    # สำหรับการใช้งานจริง ควรระบุ GUID ของกฎแต่ละข้อผ่าน GPO หรือสคริปต์เพิ่มเติม
    Set-ItemProperty -Path $RegPath -Name $ValueName -Value 1 -Type DWord -Force

    $Msg = "ASR Rules policy structure has been set to Enabled."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
}
catch {
    $ErrorMsg = "Failed to fix: $_"
    Write-Host $ErrorMsg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $ErrorMsg
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }