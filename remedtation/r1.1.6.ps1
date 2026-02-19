# ==============================================================
# CIS Check: 1.1.6 (L1) - Remediation Script
# Description: Ensure 'Relax minimum password length limits' is set to 'Enabled' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.1.6: Ensure 'Relax minimum password length limits' is Enabled"
Write-Host "=============================================================="


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
        $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    
    try {
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SAM"
        if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        
        Set-ItemProperty -Path $RegPath -Name "RelaxMinimumPasswordLengthLimits" -Value $DesiredValue -Type DWord -Force
        
        $NewValue = Get-RelaxLimit
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