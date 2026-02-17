# ==============================================================
# CIS Check: 18.10.43.6.1.2 (L1) - Remediation Script
# Description: Configure Attack Surface Reduction rules: Set the state for each ASR rule (Automated)
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_18_10_43_6_1_2.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
$DesiredValue = "1"

$Rules = @(
    [pscustomobject]@{ Guid = "26190899-1602-49e8-8b27-eb1d0a1ce869"; Description = "Block Office communication applications from creating child processes" },
    [pscustomobject]@{ Guid = "3b576869-a4ec-4529-8536-b80a7769e899"; Description = "Block Office applications from creating executable content" },
    [pscustomobject]@{ Guid = "56a863a9-875e-4185-98a7-b882c64b5ce5"; Description = "Block abuse of exploited vulnerable signed drivers" },
    [pscustomobject]@{ Guid = "5beb7efe-fd9a-4556-801d-275e5ffc04cc"; Description = "Block execution of potentially obfuscated scripts" },
    [pscustomobject]@{ Guid = "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84"; Description = "Block Office applications from injecting code into other processes" },
    [pscustomobject]@{ Guid = "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c"; Description = "Block Adobe Reader from creating child processes" },
    [pscustomobject]@{ Guid = "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2"; Description = "Block credential stealing from LSASS" },
    [pscustomobject]@{ Guid = "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4"; Description = "Block untrusted and unsigned processes that run from USB" },
    [pscustomobject]@{ Guid = "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550"; Description = "Block executable content from email client and webmail" },
    [pscustomobject]@{ Guid = "d3e037e1-3eb8-44c8-a917-57927947596d"; Description = "Block JavaScript or VBScript from launching downloaded executable content" },
    [pscustomobject]@{ Guid = "d4f940ab-401b-4efc-aadc-ad5f3c50688a"; Description = "Block Office applications from creating child processes" },
    [pscustomobject]@{ Guid = "e6db77e5-3df2-4cf1-b95a-636979351e5b"; Description = "Block persistence through WMI event subscriptions" }
)

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.43.6.1.2: Configure Attack Surface Reduction rules"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-RuleValue {
    param(
        [pscustomobject]$Rule
    )
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        return [string](Get-ItemPropertyValue -Path $RegPath -Name $Rule.Guid -ErrorAction Stop)
    } catch {
        return $null
    }
}

function Set-RuleValue {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [pscustomobject]$Rule
    )
    if (-not $PSCmdlet.ShouldProcess("$RegPath\$($Rule.Guid)", "Set Attack Surface Reduction rule state")) {
        return
    }
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name $Rule.Guid -Value $DesiredValue -Type String -Force
}

$Status = "COMPLIANT"
foreach ($Rule in $Rules) {
    $RuleDesc = "$($Rule.Guid) - $($Rule.Description)"
    $Msg = "Processing ASR rule $RuleDesc"
    Write-Host $Msg
    Add-Content -Path $LogFile -Value $Msg

    $CurrentValue = Get-RuleValue -Rule $Rule
    if ($CurrentValue -eq $DesiredValue) {
        $SuccessMsg = "Rule already set to $DesiredValue."
        Write-Host $SuccessMsg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $SuccessMsg
        continue
    }

    $InfoMsg = "Current value is '$CurrentValue'. Setting to $DesiredValue."
    Write-Host $InfoMsg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $InfoMsg
    try {
        Set-RuleValue -Rule $Rule
        $NewValue = Get-RuleValue -Rule $Rule
        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Rule set successfully. New value is $NewValue."
            Write-Host $ResultMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $ResultMsg
        } else {
            $FailMsg = "Verification failed. Current value remains '$NewValue'."
            Write-Host $FailMsg -ForegroundColor Red
            Add-Content -Path $LogFile -Value $FailMsg
            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to set rule: $_"
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