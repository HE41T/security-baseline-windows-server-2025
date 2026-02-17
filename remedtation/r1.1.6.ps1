# ==============================================================
# CIS Check: 1.1.6 (L1) - Remediation Script
# Description: Ensure 'Relax minimum password length limits' is set to 'Enabled'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_relax_pw_limits.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.1.6: Ensure 'Relax minimum password length limits' is Enabled"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

function Get-RelaxLimit {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SAM"
    $RegName = "RelaxMinimumPasswordLengthLimits"
    try {
        $Item = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        if ($Item) { return [int]$Item.$RegName }
        return 0 # Default if missing
    } catch {
        return -1
    }
}

$CurrentValue = Get-RelaxLimit

if ($CurrentValue -eq $DesiredValue) {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg

    try {
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SAM"
        if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        Set-ItemProperty -Path $RegPath -Name "RelaxMinimumPasswordLengthLimits" -Value $DesiredValue -Type DWord -Force
        
        $NewValue = Get-RelaxLimit
        if ($NewValue -eq $DesiredValue) {
             $ResultMsg = "Fixed. New value is $NewValue."
             Write-Host $ResultMsg -ForegroundColor Green
             Add-Content -Path $LogFile -Value $ResultMsg
             $Status = "COMPLIANT"
        } else {
             $FailMsg = "Verification failed. Value remains $NewValue"
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