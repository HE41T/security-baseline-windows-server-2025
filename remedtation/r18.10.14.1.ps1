# ==============================================================
# CIS Check: 18.10.14.1 (L1) - Remediation Script
# Description: Ensure 'Require PIN for pairing' is set to 'Enabled: First Time' OR 'Enabled: Always'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Wireless Display > Require PIN for pairing
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WirelessDisplay
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_require_pin_for_pairing.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WirelessDisplay"
$ValueName = "RequirePinForPairing"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.14.1: Ensure 'Require PIN for pairing' is Enabled (First Time or Always)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-RequirePinForPairingValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return 0
        }

        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return -1
    }
}

$CurrentValue = Get-RequirePinForPairingValue

if ($CurrentValue -eq -1) {
    $Msg = "[!] Error: Cannot read registry value."
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -ne $DesiredValue) {
    $Msg = "Value is off ($CurrentValue). Fixing to Enabled: First Time ($DesiredValue)..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg

    try {
        if (-not (Test-Path -Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }

        Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type DWord -Force

        $NewValue = Get-RequirePinForPairingValue

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
    $Msg = "Value is already set to $CurrentValue (Enabled: First Time). No action needed."
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
