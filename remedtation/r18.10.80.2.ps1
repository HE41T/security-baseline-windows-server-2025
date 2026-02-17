# ==============================================================
# CIS Check: 18.10.80.2 (L1) - Remediation Script
# Description: Ensure 'Allow Windows Ink Workspace' is set to 'Enabled: On, but disallow access above lock' OR 'Enabled: Disabled' (Automated)
# Instructions: Configure the setting through the Security Policy INF template (ps1_output/auto_all_ps1s) or secpol.msc
# ==============================================================
$LogFile = "C:\Windows\Temp\remediate_18.10.80.2.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
$ValueName = "AllowWindowsInkWorkspace"
$DesiredValue = 0
$StartMsg = "Remediation started: $Date"

Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.80.2: Ensure 'Allow Windows Ink Workspace' is restricted above the lock"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-SettingValue {
	try {
		if (-not (Test-Path -Path $RegPath)) {
			return $null
		}
		return Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
	} catch {
		return $null
	}
}

function Set-SettingValue {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param()
	if (-not $PSCmdlet.ShouldProcess("$RegPath\$ValueName", "Set $ValueName to $DesiredValue")) {
		return
	}
	if (-not (Test-Path -Path $RegPath)) {
		New-Item -Path $RegPath -Force | Out-Null
	}
	Set-ItemProperty -Path $RegPath -Name $ValueName -Value $DesiredValue -Type DWord -Force
}

$CurrentValue = Get-SettingValue
$Status = "COMPLIANT"
if ($CurrentValue -eq $DesiredValue) {
	$Msg = "Value is already $DesiredValue. No action needed."
	Write-Host $Msg -ForegroundColor Green
	Add-Content -Path $LogFile -Value $Msg
} else {
	$Msg = "Current value is '$CurrentValue'. Setting to recommended value $DesiredValue."
	Write-Host $Msg -ForegroundColor Yellow
	Add-Content -Path $LogFile -Value $Msg
	try {
		Set-SettingValue
		$NewValue = Get-SettingValue
		if ($NewValue -eq $DesiredValue) {
			$ResultMsg = "Configured. New value is $NewValue."
			Write-Host $ResultMsg -ForegroundColor Green
			Add-Content -Path $LogFile -Value $ResultMsg
		} else {
			$FailMsg = "Verification failed. Current value remains '$NewValue'."
			Write-Host $FailMsg -ForegroundColor Red
			Add-Content -Path $LogFile -Value $FailMsg
			$Status = "NON-COMPLIANT"
		}
	} catch {
		$ErrorMsg = "Failed to set registry value: $_"
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
