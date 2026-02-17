# ==============================================================
# CIS Check: 19.7.8.1 (L1) - Remediation Script
# Description: Ensure 'Configure Windows spotlight on lock screen' is set to 'Disabled' (Automated)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_19.7.8.1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\CloudContent"
$ValueName = "ConfigureWindowsSpotlight"
$DisabledValue = 2
$StartMsg = "Remediation started: $Date"

Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 19.7.8.1: Disable Windows Spotlight on the lock screen"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-UserSetting {
    param([string]$Sid)
    try {
        $Path = Join-Path -Path "HKU:\$Sid" -ChildPath $SubKey
        if (-not (Test-Path -Path $Path)) {
            return $null
        }
        return Get-ItemPropertyValue -Path $Path -Name $ValueName -ErrorAction Stop
    } catch {
        return $null
    }
}

function Set-UserSetting {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$Sid,
        [int]$Value
    )
    $Path = Join-Path -Path "HKU:\$Sid" -ChildPath $SubKey
    if (-not $PSCmdlet.ShouldProcess($Path, "Set $ValueName to $Value")) {
        return
    }
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $ValueName -Value $Value -Type DWord -Force
}

$Status = "COMPLIANT"
$UserSids = Get-ChildItem HKU: | Where-Object {
    $n = $_.Name
    ([regex]::IsMatch($n, 'HKEY_USERS\\S-1-5-') -and -not [regex]::IsMatch($n, '_Classes$'))
} | ForEach-Object {
    Split-Path -Path $_.Name -Leaf
} | Sort-Object -Unique

if (-not $UserSids) {
    $WarnMsg = "No user hives found; cannot enforce Windows Spotlight policy."
    Write-Host $WarnMsg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $WarnMsg
    $Status = "NON-COMPLIANT"
} else {
    foreach ($Sid in $UserSids) {
        $HeaderMsg = "Processing user hive $Sid"
        Write-Host $HeaderMsg
        Add-Content -Path $LogFile -Value $HeaderMsg

        $CurrentValue = Get-UserSetting -Sid $Sid
        if ($CurrentValue -eq $DisabledValue) {
            $SkipMsg = "$Sid already disables Windows Spotlight on the lock screen."
            Write-Host $SkipMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $SkipMsg
            continue
        }

        $InfoMsg = "$Sid has value '$CurrentValue'. Setting to $DisabledValue."
        Write-Host $InfoMsg -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value $InfoMsg
        try {
            Set-UserSetting -Sid $Sid -Value $DisabledValue
            $NewValue = Get-UserSetting -Sid $Sid
            if ($NewValue -eq $DisabledValue) {
                $SuccessMsg = "$Sid Windows Spotlight policy applied successfully."
                Write-Host $SuccessMsg -ForegroundColor Green
                Add-Content -Path $LogFile -Value $SuccessMsg
            } else {
                $FailMsg = "$Sid verification failed; now has value '$NewValue'."
                Write-Host $FailMsg -ForegroundColor Red
                Add-Content -Path $LogFile -Value $FailMsg
                $Status = "NON-COMPLIANT"
            }
        } catch {
            $ErrorMsg = "$Sid remediation failed: $_"
            Write-Host $ErrorMsg -ForegroundColor Red
            Add-Content -Path $LogFile -Value $ErrorMsg
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