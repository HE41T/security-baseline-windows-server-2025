# ==============================================================
# CIS Check: 18.10.18.4 (L1) - Remediation Script
# Description: Ensure 'Enable App Installer Local Archive Malware Scan Override' is set to 'Disabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Desktop App Installer > Enable App Installer Local Archive Malware Scan Override
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller\EnableLocalArchiveMalwareScanOverride
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_appinstaller_malwarescan_override.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"
$ValueName = "EnableLocalArchiveMalwareScanOverride"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.18.4: Ensure 'Enable App Installer Local Archive Malware Scan Override' is Disabled"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-AppInstallerMalwareScanOverrideValue {
    try {
    # --- Auto-Generated LGPO Injection ---
    $LgpoContent = @"
Computer
SOFTWARE\Policies\Microsoft\Windows\AppInstaller
EnableLocalArchiveMalwareScanOverride
DWORD:0
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
        return -1
    }
}

$CurrentValue = Get-AppInstallerMalwareScanOverrideValue

if ($CurrentValue -eq -1 -or $CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect or missing. Fixing to $DesiredValue (Disabled)..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg

    try {
    # --- Auto-Generated LGPO Injection ---
    $LgpoContent = @"
Computer
SOFTWARE\Policies\Microsoft\Windows\AppInstaller
EnableLocalArchiveMalwareScanOverride
DWORD:0
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
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $ErrorMsg
        $Status = "NON-COMPLIANT"
    }
} else {
    $Msg = "Value is already Disabled ($CurrentValue). No action required."
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