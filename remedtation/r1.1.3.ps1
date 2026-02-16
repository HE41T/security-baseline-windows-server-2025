# ==============================================================
# CIS Check: 1.1.3 (L1) - Remediation Script
# Description: Ensure 'Minimum password age' is set to '1 or more day(s)'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_min_password_age.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.1.3: Ensure 'Minimum password age' is >= $DesiredValue day(s)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

# 1. ฟังก์ชันสำหรับอ่านค่าปัจจุบัน
function Get-MinPasswordAge {
    try {
        $NetOutput = net accounts | Select-String "Minimum password age"
        if ($NetOutput) {
            $ValStr = ($NetOutput.ToString() -split ":")[1].Trim()
            $Num = $ValStr -replace "[^0-9]", ""
            if ([string]::IsNullOrWhiteSpace($Num)) { return -1 }
            return [int]$Num
        }
        return -1
    } catch {
        return -1
    }
}

# ตรวจสอบค่าก่อนแก้ไข
$CurrentValue = Get-MinPasswordAge

if ($CurrentValue -eq -1) {
    $Msg = "[!] Error: Could not read current policy."
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -lt $DesiredValue) {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    
    try {
        # แก้ไขโดยใช้ Native Command (/minpwage)
        $Proc = Start-Process "net.exe" -ArgumentList "accounts /minpwage:$DesiredValue" -NoNewWindow -Wait -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            # ตรวจสอบซ้ำ (Verify)
            $NewValue = Get-MinPasswordAge
            
            if ($NewValue -ge $DesiredValue) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                Add-Content -Path $LogFile -Value $ResultMsg
                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue"
                Write-Host $FailMsg -ForegroundColor Red
                Add-Content -Path $LogFile -Value $FailMsg
                $Status = "NON-COMPLIANT"
            }
        } else {
            throw "Net accounts command failed with exit code $($Proc.ExitCode)"
        }
        
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $ErrorMsg
        $Status = "NON-COMPLIANT"
    }

} else {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }