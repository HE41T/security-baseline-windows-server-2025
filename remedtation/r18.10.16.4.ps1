# ==============================================================
# CIS Check: 18.10.16.4 (L1) - Remediation Script
# Description: Ensure 'Do not show feedback notifications' is set to 'Enabled'
# GPO Path: Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds > Do not show feedback notifications
# Registry Path: HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_feedback_notifications.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection"
$ValueName = "DoNotShowFeedbackNotifications"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.16.4: Ensure 'Do not show feedback notifications' is Enabled"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-FeedbackNotificationsValue {
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

$CurrentValue = Get-FeedbackNotificationsValue

if ($CurrentValue -eq -1) {
    $Msg = "[!] Error: Cannot read registry value."
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
} elseif ($CurrentValue -ne $DesiredValue) {
    $Msg = "Value is $CurrentValue. Setting to $DesiredValue."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    try {
        if (-not (Test-Path -Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type DWord -Force
        $NewValue = Get-FeedbackNotificationsValue
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
