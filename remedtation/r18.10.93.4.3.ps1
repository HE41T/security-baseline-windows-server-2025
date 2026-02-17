# ==============================================================
# CIS Check: 18.10.93.4.3 (L1) - Remediation Script
# Description: Ensure 'Select when Quality Updates are received' is set to 'Enabled: 0 days' (Automated)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_18.10.93.4.3.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$Settings = @(
    [pscustomobject]@{ Name = "DeferQualityUpdates"; Value = 1; Description = "Enable deferral of quality updates" },
    [pscustomobject]@{ Name = "DeferQualityUpdatesPeriodInDays"; Value = 0; Description = "Set quality update deferral to 0 days" }
)
$StartMsg = "Remediation started: $Date"

Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.93.4.3: Set quality update deferral to 0 days"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-SettingValue {
    param(
        [pscustomobject]$Setting
    )
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        return Get-ItemPropertyValue -Path $RegPath -Name $Setting.Name -ErrorAction Stop
    } catch {
        return $null
    }
}

function Set-SettingValue {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [pscustomobject]$Setting
    )
    if (-not $PSCmdlet.ShouldProcess("$RegPath\$($Setting.Name)", "Set $($Setting.Name) to $($Setting.Value)")) {
        return
    }
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name $Setting.Name -Value $Setting.Value -Type DWord -Force
}

$Status = "COMPLIANT"
foreach ($Setting in $Settings) {
    $HeaderMsg = "Processing $($Setting.Name): $($Setting.Description)"
    Write-Host $HeaderMsg
    Add-Content -Path $LogFile -Value $HeaderMsg

    $CurrentValue = Get-SettingValue -Setting $Setting
    if ($CurrentValue -eq $Setting.Value) {
        $InfoMsg = "Current value for $($Setting.Name) is already $($Setting.Value)."
        Write-Host $InfoMsg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $InfoMsg
        continue
    }

    $InfoMsg = "Current value is '$CurrentValue'. Setting to $($Setting.Value)."
    Write-Host $InfoMsg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $InfoMsg
    try {
        Set-SettingValue -Setting $Setting
        $NewValue = Get-SettingValue -Setting $Setting
        if ($NewValue -eq $Setting.Value) {
            $SuccessMsg = "Configured $($Setting.Name). New value is $NewValue."
            Write-Host $SuccessMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $SuccessMsg
        } else {
            $FailMsg = "Verification failed for $($Setting.Name). Current value is '$NewValue'."
            Write-Host $FailMsg -ForegroundColor Red
            Add-Content -Path $LogFile -Value $FailMsg
            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to set $($Setting.Name): $_"
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