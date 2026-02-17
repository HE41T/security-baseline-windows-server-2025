# ==============================================================
# CIS Check: 18.9.19.3 (L1) - Remediation Script
# Description: Ensure 18.9.19.3 NoGPOListChanges is set to 1
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
$RegName = "NoGPOListChanges"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.9.19.3: Set $RegName to $DesiredValue"
Write-Host "=============================================================="

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
    
    try {
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        # เนเธเนเนเธเธเนเธฒ Registry
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
} else {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
