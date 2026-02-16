# ==============================================================
# CIS Check: ShutdownWithoutLogon - Audit Script
# Description: Ensure 'Shutdown: Allow system to be shut down without having to log on' is set to 'Disabled'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "ShutdownWithoutLogon"
$DesiredValue = 0

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control: Ensure ShutdownWithoutLogon is set to $DesiredValue"
Write-Host "=============================================================="

# ตรวจสอบค่า (ใช้ ErrorAction SilentlyContinue เพื่อกัน Error กรณีไม่มี Key)
$CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name

# ตรวจสอบว่ามีค่าอยู่จริงหรือไม่
if ($null -eq $CurrentValue) {
    Write-Host "[!] Registry Key not found or empty." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    # กรณีค่าตรงตามที่กำหนด (ถูกต้อง)
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    # กรณีค่าไม่ตรง (ผิด)
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

# Return Exit Code for Ansible/CI
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }