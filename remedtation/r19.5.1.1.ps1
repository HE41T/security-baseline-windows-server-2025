# ==============================================================
# CIS Check: 19.5.1.1 (L1) - Remediation Script
# Description: Set 'Turn off toast notifications on the lock screen' to 'Enabled' (1)
# ==============================================================

$LogFile = "$env:TEMP\remediate_lockscreen_notifications.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$ValueName = "NoToastApplicationNotificationOnLockScreen"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Disabling toast notifications on Lock Screen (Registry: 1)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "Remediation started: $Date"

try {
    # --- Auto-Generated LGPO Injection ---
    $LgpoContent = @"
User
Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications
NoToastApplicationNotificationOnLockScreen
DWORD:1
"@
    
    $LgpoFile = "C:\Windows\Temp\lgpo_temp_$ValueName.txt"
    Set-Content -Path $LgpoFile -Value $LgpoContent -Encoding Ascii

    if (Test-Path "C:\Windows\Temp\LGPO.exe") {
        & "C:\Windows\Temp\LGPO.exe" /q /t $LgpoFile | Out-Null
        gpupdate /force | Out-Null
        Write-Host "Success: Applied via LGPO.exe (GPO & Registry updated)" -ForegroundColor Green
        Add-Content -Path $LogFile -Value "Status: COMPLIANT - Applied via LGPO"
        $ExitCode = 0
    } else {
        Write-Host "[!] LGPO.exe not found! Applying to Registry only." -ForegroundColor Yellow
        if (-not (Test-Path -Path "$RegPath")) { New-Item -Path "$RegPath" -Force | Out-Null }
        Set-ItemProperty -Path "$RegPath" -Name "$ValueName" -Value $DesiredValue -Type DWord -Force
        $ExitCode = 0
    }

    if (Test-Path $LgpoFile) { Remove-Item -Path $LgpoFile -Force }
    # ---------------------------------------
} catch {
    Write-Host "Error: Failed to set registry value. $_" -ForegroundColor Red
    Add-Content -Path $LogFile -Value "Status: FAILED - $_"
    $ExitCode = 1
}

Write-Host "=============================================================="
exit $ExitCode