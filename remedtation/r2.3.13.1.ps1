# ==============================================================
# CIS Check: ShutdownWithoutLogon - Remediation Script
# Description: Configure 'Shutdown: Allow system to be shut down without having to log on' to 'Disabled'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_shutdown_without_logon.log"
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
Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

# ตรวจสอบค่าก่อนแก้ (Idempotency)
try {
    $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
} catch {
    $CurrentValue = $null
}

if ($CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    
    try {
        # สร้าง Path หากไม่มี
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        
        # แก้ไขค่า
        Set-ItemProperty -Path $Path -Name $Name -Value $DesiredValue -Type DWord -Force
        
        $ResultMsg = "Fixed."
        Write-Host $ResultMsg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $ResultMsg
        
        $Status = "COMPLIANT"
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $ErrorMsg
        
        $Status = "NON-COMPLIANT"
    }

} else {
    $Msg = "Value is correct. No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    
    $Status = "COMPLIANT"
}

# ส่วนสรุปจบ
Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
# บันทึกสถานะสุดท้ายลงไฟล์
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

# Return Exit Code for Ansible/CI
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }