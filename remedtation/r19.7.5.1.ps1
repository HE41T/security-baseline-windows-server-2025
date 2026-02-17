# ==============================================================
# CIS Check: 19.7.5.1 (L1) - Remediation Script
# Description: Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled' (Automated)
# Instructions: Set the per-user registry key under each loaded HKU hive
# ==============================================================

$LogFile = "C:\\Windows\\Temp\\remediate_19.7.5.1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubPath = "Software\Microsoft\Windows\CurrentVersion\Policies\Attachments"
$ValueName = "SaveZoneInformation"
$DesiredValue = 2

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 19.7.5.1: Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled' (Automated)"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Set-UserValue {

    param(
        [Parameter(Mandatory=$true)]
        [string]$Sid
    )
    $RegRoot = Join-Path "HKU:\$Sid" "$SubPath"
    if (-not (Test-Path -Path $RegRoot)) {
        New-Item -Path $RegRoot -Force | Out-Null
    }
    Set-ItemProperty -Path $RegRoot -Name $ValueName -Value $DesiredValue -Type DWord -Force
    try {
        $Current = Get-ItemPropertyValue -Path $RegRoot -Name $ValueName -ErrorAction Stop
        return [int]$Current
    } catch {
        return $null
    }
}

$Status = "COMPLIANT"
$Sids = Get-ChildItem HKU:\ | Where-Object { $_.PSChildName -match '^S-1-5-21-' }
if (-not $Sids) {
    $Msg = "No user hives found under HKU:\"; Write-Host $Msg -ForegroundColor Yellow; Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
} else {
    foreach ($Sid in $Sids) {
        $NewValue = Set-UserValue -Sid $Sid.PSChildName
        if ($NewValue -eq $DesiredValue) {
            $Msg = "$($Sid.PSChildName): Set to $NewValue."; Write-Host $Msg -ForegroundColor Green; Add-Content -Path $LogFile -Value $Msg
        } else {
            $Msg = "$($Sid.PSChildName): Failed to set value (current $NewValue)."; Write-Host $Msg -ForegroundColor Red; Add-Content -Path $LogFile -Value $Msg
            $Status = "NON-COMPLIANT"
        }
    }
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
