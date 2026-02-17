# ==============================================================
# CIS Check: 19.5.1.1 (L1) - Remediation Script
# Description: Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled' (Automated)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_19.5.1.1.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$ValueName = "NoToastApplicationNotificationOnLockScreen"
$DesiredValue = 1
$StartMsg = "Remediation started: $Date"

Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 19.5.1.1: Disable toast notifications on the lock screen"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-UserValue {
    param(
        [string]$Sid
    )
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

function Set-UserValue {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Sid
    )
    $Path = Join-Path -Path "HKU:\$Sid" -ChildPath $SubKey
    if (-not $PSCmdlet.ShouldProcess("$Path", "Set $ValueName to $DesiredValue")) {
        return
    }
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $ValueName -Value $Value -Type DWord -Force
}

$Status = "COMPLIANT"
$UserSids = Get-ChildItem HKU: | Where-Object {
    ($_.Name -match 'HKEY_USERS\\S-1-5-') -and ($_.Name -notmatch '_Classes$')
} | ForEach-Object {
    Split-Path -Path $_.Name -Leaf
} | Sort-Object -Unique

if (-not $UserSids) {
    $WarnMsg = "No user hives found; cannot apply setting."
    Write-Host $WarnMsg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $WarnMsg
    $Status = "NON-COMPLIANT"
} else {
    foreach ($Sid in $UserSids) {
        $HeaderMsg = "Processing user hive $Sid"
        Write-Host $HeaderMsg
        Add-Content -Path $LogFile -Value $HeaderMsg

        $CurrentValue = Get-UserValue -Sid $Sid
        if ($CurrentValue -eq $DesiredValue) {
            $SkipMsg = "$Sid already enforces lock-screen toast suppression."
            Write-Host $SkipMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $SkipMsg
            continue
        }

        $InfoMsg = "$Sid currently has value '$CurrentValue'. Setting to $DesiredValue."
        Write-Host $InfoMsg -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value $InfoMsg
        try {
            Set-UserValue -Sid $Sid -Value $DesiredValue
            $NewValue = Get-UserValue -Sid $Sid
            if ($NewValue -eq $DesiredValue) {
                $SuccessMsg = "$Sid toast lock-screen policy applied successfully."
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