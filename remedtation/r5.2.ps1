$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler"

try {
    # 1. ตั้งค่า Registry ให้เป็น 4 (Disabled)
    Set-ItemProperty -Path $regPath -Name "Start" -Value 4 -ErrorAction Stop
    Write-Host "SUCCESS: Member Server Registry 'Start' set to 4"

    # 2. สั่งหยุด Service ทันทีและ Force เพื่อไม่ให้ค้าง Running
    $service = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
    if ($service.Status -ne 'Stopped') {
        Stop-Service -Name "Spooler" -Force -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "SUCCESS: Spooler service stopped"
    }
    exit 0
} catch {
    Write-Host "REMEDIATION FAILED: $($_.Exception.Message)"
    exit 1
}