# ==============================================================
# CIS Check: 18.1.1.1 (L1) - Remediation Script
# Description: Ensure 'Prevent enabling lock screen camera' is set to 'Enabled'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_lock_screen_camera.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
$Name = "NoLockScreenCamera"
$DesiredValue = 1

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Control 18.1.1.1: Set $Name to $DesiredValue"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "`n==============================================================`nRemediation started: $Date"

try {
    # ตรวจสอบค่าก่อนแก้ไข
    $CurrentValue = (Get-ItemProperty -Path $RegPath -Name $Name -ErrorAction SilentlyContinue).$Name
    
    if ($CurrentValue -eq $DesiredValue) {
        $Msg = "Value is already correct ($CurrentValue). No action needed."
        Write-Host $Msg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $Msg
        $Status = "COMPLIANT"
    } else {
        Write-Host "Value is incorrect or missing. Fixing..." -ForegroundColor Yellow
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        Set-ItemProperty -Path $RegPath -Name $Name -Value $DesiredValue -Type DWord -Force
        
        # Verify
        $NewValue = (Get-ItemProperty -Path $RegPath -Name $Name).$Name
        if ($NewValue -eq $DesiredValue) {
            $Msg = "Fixed successfully. New value is $NewValue."
            Write-Host $Msg -ForegroundColor Green
            $Status = "COMPLIANT"
        } else { throw "Verification failed." }
    }
} catch {
    $Msg = "Failed to fix: $_"
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}

Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }