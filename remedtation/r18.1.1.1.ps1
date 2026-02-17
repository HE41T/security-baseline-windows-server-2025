# ==============================================================
# CIS Check: 18.1.2.2 (L1) - Remediation Script
# Description: Ensure 'Allow users to enable online speech recognition services' is set to 'Disabled'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0
$RegPath = "HKLM:\Software\Policies\Microsoft\InputPersonalization"
$RegName = "AllowInputPersonalization"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.1.2.2: Ensure 'Online speech recognition' is Disabled ($DesiredValue)"
Write-Host "=============================================================="


function Get-RegistryValue {
    try {
        $Val = (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue).$RegName
        if ($null -eq $Val) { return -1 }
        return [int]$Val
    } catch { return -1 }
}

$CurrentValue = Get-RegistryValue

if ($CurrentValue -eq $DesiredValue) {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
    
    $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    
    
    try {
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type DWord -Force
        
        $NewValue = Get-RegistryValue
        
        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Fixed. New value is $NewValue."
            Write-Host $ResultMsg -ForegroundColor Green
            
            $Status = "COMPLIANT"
        } else {
            $FailMsg = "Verification failed. Value remains $NewValue"
            Write-Host $FailMsg -ForegroundColor Red
            
            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        
        $Status = "NON-COMPLIANT"
    }
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="


if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }