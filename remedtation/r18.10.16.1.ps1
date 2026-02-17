# ==============================================================
# CIS Check: 18.10.16.1 (L1) - Remediation Script
# Description: Ensure 'Allow Diagnostic Data' is set to 'Enabled: Diagnostic data off (not recommended)' OR 'Enabled: Send required diagnostic data'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Allow Telemetry
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_allow_diagnostic_data.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
$ValueName = "AllowTelemetry"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.16.1: Ensure 'Allow Diagnostic Data' is set to Send required diagnostic data"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-AllowTelemetryValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 3
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return -1
    }
}

$CurrentValue = Get-AllowTelemetryValue

if ($CurrentValue -eq -1) {
    $Msg = "[!] Error: Cannot read registry value."
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -ne $DesiredValue) {
    $Msg = "Value is $CurrentValue. Updating to $DesiredValue (Send required diagnostic data)."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg

    try {
        if (-not (Test-Path -Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }

        Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type DWord -Force

        $NewValue = Get-AllowTelemetryValue

        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Fixed. New value is $NewValue."
            Write-Host $ResultMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $ResultMsg
            $Status = "COMPLIANT"
        } else {
            $FailMsg = "Verification failed. Current value is $NewValue."
            Write-Host $FailMsg -ForegroundColor Red
            Add-Content -Path $LogFile -Value $FailMsg
            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $ErrorMsg
        $Status = "NON-COMPLIANT"
    }
} else {
    $Msg = "Value is already $CurrentValue. No action needed."
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
