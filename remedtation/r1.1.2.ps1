# ==============================================================
# CIS Check: 1.1.2 (L1) - Remediation Script
# Description: Ensure 'Maximum password age' is set to '365 or fewer days, but not 0' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$TargetValue = 365

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.1.2: Ensure 'Maximum password age' is set to $TargetValue days"
Write-Host "=============================================================="


# 1. ฟังก์ชันสำหรับอ่านค่าปัจจุบัน
function Get-MaxPasswordAge {
    try {
        $NetOutput = net accounts | Select-String "Maximum password age"
        if ($NetOutput) {
            $ValStr = ($NetOutput.ToString() -split ":")[1].Trim()
            if ($ValStr -match "Unlimited") { return 0 } # Treat Unlimited as 0
            $Num = $ValStr -replace "[^0-9]", ""
            if ([string]::IsNullOrWhiteSpace($Num)) { return -1 }
            return [int]$Num
        }
        return -1
    } catch {
        return -1
    }
}

# อ่านค่าปัจจุบัน
$CurrentValue = Get-MaxPasswordAge

# Logic: ถ้าค่าปัจจุบัน เท่ากับ 365 เป๊ะๆ -> จบ (COMPLIANT)
#       ถ้าไม่ใช่ (เป็น 0, 42, 999, หรือ error) -> แก้ (FIX)
if ($CurrentValue -eq $TargetValue) {
    $Msg = "Value is already correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
} else {
    # เข้าสู่กระบวนการแก้ไข
    $Msg = "Value is incorrect ($CurrentValue). Fixing to $TargetValue..."
    Write-Host $Msg -ForegroundColor Yellow
        
    try {
        # แก้ไขโดยเรียกคำสั่งตรงๆ (Direct Invocation) ไม่ใช้ Start-Process เพื่อเลี่ยงการค้าง
        $Output = & net.exe accounts /maxpwage:$TargetValue 2>&1
        
        # เช็ค $LASTEXITCODE ทันทีหลังรันคำสั่ง
        if ($LASTEXITCODE -eq 0) {
            # ตรวจสอบซ้ำ (Verify)
            $NewValue = Get-MaxPasswordAge
            
            if ($NewValue -eq $TargetValue) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue"
                Write-Host $FailMsg -ForegroundColor Red
                                $Status = "NON-COMPLIANT"
            }
        } else {
            # กรณี net accounts error
            $FailMsg = "Command failed. Output: $Output"
            Write-Host $FailMsg -ForegroundColor Red
                        $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Exception during fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
                $Status = "NON-COMPLIANT"
    }
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }