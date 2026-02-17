# ==============================================================
# CIS Check: 18.10.93.4.2 (L1) - Remediation Script
# Description: Ensure 'Select when Preview Builds and Feature Updates are received' is set to 'Enabled: 180 or more days' (Automated)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_18.10.93.4.2.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$SubKey = "Software\Policies\Microsoft\Windows\WindowsUpdate"
$ValueName = "DeferFeatureUpdates"
$PeriodValueName = "DeferFeatureUpdatesPeriodInDays"
$DesiredValue = 1
$DesiredDays = 180
$StartMsg = "Remediation started: $Date"

Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.93.4.2: Ensure preview/feature updates are deferred 180 days"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-UserSettingValue {
    param(
        [string]$Sid,
        [string]$PropertyName
    )
    try {
        $Path = Join-Path -Path "HKU:\$Sid" -ChildPath $SubKey
        if (-not (Test-Path -Path $Path)) {
            return $null
        }
        return Get-ItemPropertyValue -Path $Path -Name $PropertyName -ErrorAction Stop
    } catch {
        return $null
    }
}

function Set-UserSettingValue {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$Sid,
        [string]$PropertyName,
        [int]$Value
    )
    $Path = Join-Path -Path "HKU:\$Sid" -ChildPath $SubKey
    if (-not $PSCmdlet.ShouldProcess($Path, "Set $PropertyName to $Value")) {
        return
    }
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $PropertyName -Value $Value -Type DWord -Force
}

$Status = "COMPLIANT"
$UserSids = Get-ChildItem HKU: | Where-Object {
    $n = $_.Name
    ([regex]::IsMatch($n, 'HKEY_USERS\\S-1-5-') -and -not [regex]::IsMatch($n, '_Classes$'))
} | ForEach-Object {
    Split-Path -Path $_.Name -Leaf
} | Sort-Object -Unique

if (-not $UserSids) {
    $WarnMsg = "No user hives found under HKU: skipping remediation."
    Write-Host $WarnMsg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $WarnMsg
    $Status = "NON-COMPLIANT"
} else {
    foreach ($Sid in $UserSids) {
        $HeaderMsg = "Processing user hive: $Sid"
        Write-Host $HeaderMsg
        Add-Content -Path $LogFile -Value $HeaderMsg

        $CurrentFeatureValue = Get-UserSettingValue -Sid $Sid -PropertyName $ValueName
        $CurrentDayValue = Get-UserSettingValue -Sid $Sid -PropertyName $PeriodValueName

        if ($CurrentFeatureValue -eq $DesiredValue -and $CurrentDayValue -eq $DesiredDays) {
            $SkipMsg = "$Sid already has deferral settings configured."
            Write-Host $SkipMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $SkipMsg
            continue
        }

        $InfoMsg = "$Sid currently has values FeatureUpdates='$CurrentFeatureValue', Period='$CurrentDayValue'. Applying $DesiredValue/$DesiredDays."
        Write-Host $InfoMsg -ForegroundColor Yellow
        Add-Content -Path $LogFile -Value $InfoMsg
        try {
            Set-UserSettingValue -Sid $Sid -PropertyName $ValueName -Value $DesiredValue
            Set-UserSettingValue -Sid $Sid -PropertyName $PeriodValueName -Value $DesiredDays
            $NewFeatureValue = Get-UserSettingValue -Sid $Sid -PropertyName $ValueName
            $NewDayValue = Get-UserSettingValue -Sid $Sid -PropertyName $PeriodValueName
            if ($NewFeatureValue -eq $DesiredValue -and $NewDayValue -eq $DesiredDays) {
                $SuccessMsg = "$Sid deferral settings applied successfully."
                Write-Host $SuccessMsg -ForegroundColor Green
                Add-Content -Path $LogFile -Value $SuccessMsg
            } else {
                $FailMsg = "$Sid verification failed. Now has FeatureUpdates='$NewFeatureValue', Period='$NewDayValue'."
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