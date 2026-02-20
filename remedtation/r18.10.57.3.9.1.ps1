# ==============================================================
# CIS Check: 18.10.57.3.9.1 (L1) - Remediation Script
# Description: Set 'Always prompt for password upon connection' to 'Enabled' (1)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_rdp_prompt_password.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "fPromptForPassword"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Enforcing RDP password prompt (Registry: 1)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "Remediation started: $Date"

try {
    # --- Auto-Generated LGPO Injection ---
    $LgpoContent = @"
Computer
SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
fPromptForPassword
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