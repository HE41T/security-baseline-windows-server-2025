# ==============================================================
# CIS Check: 18.4.3 (L1) - Remediation Script
# Description: Ensure 'Configure SMB v1 server' is set to 'Disabled'
# ==============================================================


$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$RegName = "SMB1"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.4.3: Ensure SMB v1 server is Disabled ($DesiredValue)"
Write-Host "=============================================================="

# 1. ฟังก์ชันสำหรับอ่านค่าปัจจุบัน
function Get-RegistryValue {
    try {
        $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        if ($RegData -and $RegData.$RegName -ne $null) {
            return [int]$RegData.$RegName
        }
        return -1 # หาไม่เจอ
    } catch {
        return -1
    }
}

# ตรวจสอบค่าก่อนแก้ไข
$CurrentValue = Get-RegistryValue

if ($CurrentValue -eq -1 -or $CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect or missing ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    
    try {
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        # แก้ไขค่า Registry
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type DWord -Force
        
        # แถม: ปิดผ่าน SMB Service Cmdlet ด้วยเพื่อความชัวร์ (Server 2025)
        if (Get-Command Set-SmbServerConfiguration -ErrorAction SilentlyContinue) {
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -Confirm:$false | Out-Null
        }

        # ตรวจสอบซ้ำ
        $NewValue = Get-RegistryValue
        
        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Fixed. New value is $NewValue."
            Write-Host $ResultMsg -ForegroundColor Green
            
            $Status = "COMPLIANT"
        } else {
            $FailMsg = "Verification failed. Value remains $NewValue"
            Write-Host $FailMsg -ForegroundColor Red
            
            $Status = "NON-COMPLIANT"
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