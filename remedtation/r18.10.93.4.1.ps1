# ==============================================================
# CIS Check: 18.10.93.4.1 (L1) - Remediation Script
# Description: Ensure 'Manage preview builds' is set to 'Disabled' (Automated)
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_18_10_93_4_1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate"
$ValueName = "ManagePreviewBuildsPolicyValue"
$DesiredValue = 1
$ValueType = "DWord"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.93.4.1: Ensure 'Manage preview builds' is set to 'Disabled' (Automated)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-PolicyValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        if ($ValueType -eq "DWord") {
            return [int]$Value
        }
        return [string]$Value
    } catch {
        return $null
    }
}

function Set-PolicyValue {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    if (-not $PSCmdlet.ShouldProcess($RegPath, "Set $ValueName")) {
        return
    }
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type $ValueType -Force
}

$CurrentValue = Get-PolicyValue

if ($CurrentValue -eq $DesiredValue) {
    $Msg = "Value is already $CurrentValue. No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} else {
    $Msg = "Value is $CurrentValue. Setting to $DesiredValue."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    try {
        Set-PolicyValue
        $NewValue = Get-PolicyValue
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
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
