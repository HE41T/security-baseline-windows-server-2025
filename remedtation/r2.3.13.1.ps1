# ==============================================================
# CIS Check: ShutdownWithoutLogon - Remediation Script
# Description: Configure 'Shutdown: Allow system to be shut down without having to log on' to 'Disabled'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "ShutdownWithoutLogon"
$DesiredValue = 0

# เริ่มต้นเขียน Log Header
$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control: Ensure ShutdownWithoutLogon is set to $DesiredValue"
Write-Host "=============================================================="
# บันทึกลงไฟล์

# ตรวจสอบค่าก่อนแก้ (Idempotency)
try {
    $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
} catch {
    $CurrentValue = $null
}

if ($CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
        
    try {
        # สร้าง Path หากไม่มี
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        
        # แก้ไขค่า
        Set-ItemProperty -Path $Path -Name $Name -Value $DesiredValue -Type DWord -Force
        
        $ResultMsg = "Fixed."
        Write-Host $ResultMsg -ForegroundColor Green
                
        $Status = "COMPLIANT"
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
                
        $Status = "NON-COMPLIANT"
    }

} else {
    $Msg = "Value is correct. No action needed."
    Write-Host $Msg -ForegroundColor Green
        
    $Status = "COMPLIANT"
}

# ส่วนสรุปจบ
Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
# บันทึกสถานะสุดท้ายลงไฟล์

# Return Exit Code for Ansible/CI
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }