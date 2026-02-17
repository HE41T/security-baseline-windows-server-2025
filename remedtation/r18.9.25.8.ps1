# ==============================================================
# CIS Check: 18.9.25.8 (L1) - Remediation Script
# Description: Ensure 18.9.25.8 PostAuthenticationActions is set to 3
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_18.9.25.8.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 3
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"
$RegName = "PostAuthenticationActions"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.9.25.8: Set $RegName to $DesiredValue"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "
=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

function Get-RegistryValue {
    try {
        $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        if ($RegData -and $RegData.$RegName -ne $null) { return $RegData.$RegName }
        return $null
    } catch { return $null }
}

$CurrentValue = Get-RegistryValue

if ($null -eq $CurrentValue -or $CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect or missing ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    
    try {
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        # เนเธเนเนเธเธเนเธฒ Registry
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type DWord -Force
        
        $NewValue = Get-RegistryValue
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
} else {
    $Msg = "Value is correct ($CurrentValue). No action needed."
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
