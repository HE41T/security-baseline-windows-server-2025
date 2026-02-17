# ==============================================================
# CIS Check: 1.2.4 (L1) - Remediation Script
# Description: Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_lockout_window.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 15

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.2.4: Ensure 'Reset account lockout counter' is >= $DesiredValue"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

function Get-LockoutWindow {
    try {
        $NetOutput = net accounts | Select-String "Lockout observation window"
        if ($NetOutput) {
            $Val = $NetOutput.ToString() -replace "[^0-9]", ""
            if ([string]::IsNullOrWhiteSpace($Val)) { return 0 }
            return [int]$Val
        }
        return -1
    } catch {
        return -1
    }
}

$CurrentValue = Get-LockoutWindow

if ($CurrentValue -eq -1) { $CurrentValue = 0 }

if ($CurrentValue -ge $DesiredValue) {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    
    try {
        # /lockoutwindow is the parameter
        $Proc = Start-Process "net.exe" -ArgumentList "accounts /lockoutwindow:$DesiredValue" -NoNewWindow -Wait -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            $NewValue = Get-LockoutWindow
            if ($NewValue -ge $DesiredValue) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                Add-Content -Path $LogFile -Value $ResultMsg
                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue (Ensure Lockout Threshold is not 0)"
                Write-Host $FailMsg -ForegroundColor Red
                Add-Content -Path $LogFile -Value $FailMsg
                $Status = "NON-COMPLIANT"
            }
        } else {
            throw "Net accounts command failed with exit code $($Proc.ExitCode)"
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