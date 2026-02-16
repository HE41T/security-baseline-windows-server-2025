$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler"

try {
    # 1. ปรับค่า Registry เป็น 4 (Disabled)
    Set-ItemProperty -Path $regPath -Name "Start" -Value 4 -ErrorAction Stop
    Write-Host "SUCCESS: Registry 'Start' set to 4"

    # 2. สั่งหยุด Service ทันที (เพิ่มการ Force และตั้งสถานะ)
    $service = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
    if ($service) {
        # สั่งหยุดแบบ Force และรอจนกว่าจะหยุดสนิท
        Stop-Service -Name "Spooler" -Force -Confirm:$false -ErrorAction SilentlyContinue
        
        # ตรวจสอบสถานะอีกครั้งเพื่อให้แน่ใจ
        $check = Get-Service -Name "Spooler"
        if ($check.Status -eq 'Running') {
            # ถ้ายังไม่หยุด ให้ใช้คำสั่งระดับต่ำ (taskkill) เพื่อปิด Process
            taskkill /F /FI "SERVICES eq Spooler"
            Write-Host "SUCCESS: Force killed Spooler process"
        } else {
            Write-Host "SUCCESS: Service stopped successfully"
        }
    }
    exit 0
} catch {
    Write-Host "REMEDIATION FAILED: $($_.Exception.Message)"
    exit 1
}