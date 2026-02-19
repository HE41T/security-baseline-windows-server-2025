# ==============================================================
# CIS Check: 1.1.1 (L1) - Remediation Script
# Description: Ensure 'Enforce password history' is set to '24 or more password(s)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 24

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.1.1: Ensure 'Enforce password history' is >= $DesiredValue"
Write-Host "=============================================================="


# 1. ฟังก์ชันสำหรับอ่านค่าปัจจุบัน (Reusable)
function Get-PasswordHistory {
    try {
        $NetOutput = net accounts | Select-String "Length of password history maintained"
        if ($NetOutput) {
            $Val = $NetOutput.ToString() -replace "[^0-9]", ""
            if ([string]::IsNullOrWhiteSpace($Val)) { return 0 }
            return [int]$Val
        }
        return -1 # หาไม่เจอ
    } catch {
        return -1
    }
}

# ตรวจสอบค่าก่อนแก้ไข
$CurrentValue = Get-PasswordHistory

if ($CurrentValue -eq -1) {
    $Msg = "[!] Error: Could not read current password policy."
    Write-Host $Msg -ForegroundColor Red
        $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -lt $DesiredValue) {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
        
    try {
        # แก้ไขโดยใช้ Native Command
        # /uniquepw คือ parameter สำหรับ Enforce password history
        $Proc = Start-Process "net.exe" -ArgumentList "accounts /uniquepw:$DesiredValue" -NoNewWindow -Wait -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            # ตรวจสอบซ้ำ (Verify)
            $NewValue = Get-PasswordHistory
            
            if ($NewValue -ge $DesiredValue) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue"
                Write-Host $FailMsg -ForegroundColor Red
                                $Status = "NON-COMPLIANT"
            }
        } else {
            throw "Net accounts command failed with exit code $($Proc.ExitCode)"
        }
        
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
                $Status = "NON-COMPLIANT"
    }

} else {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }