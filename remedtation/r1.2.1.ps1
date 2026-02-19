# ==============================================================
# CIS Check: 1.2.1 (L1) - Remediation Script
# Description: Ensure 'Account lockout duration' is set to '15 or more minute(s)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 15

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.2.1: Ensure 'Account lockout duration' is >= $DesiredValue"
Write-Host "=============================================================="


function Get-LockoutDuration {
    try {
        $NetOutput = net accounts | Select-String "Lockout duration"
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

$CurrentValue = Get-LockoutDuration

# Note: If Lockout Threshold is 0, setting duration might fail or not show. 
# It is recommended to run 1.2.2 remediation before or allow this to enable threshold implicitly if needed, 
# but net accounts /lockoutduration usually requires threshold to be set first in some contexts.
# However, net accounts /lockoutduration:X often works directly.

if ($CurrentValue -eq -1) {
    # If not found, it might be because threshold is 0. We try to set it anyway.
    $CurrentValue = 0 
}

if ($CurrentValue -ge $DesiredValue) {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
        
    try {
        $Proc = Start-Process "net.exe" -ArgumentList "accounts /lockoutduration:$DesiredValue" -NoNewWindow -Wait -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            $NewValue = Get-LockoutDuration
            if ($NewValue -ge $DesiredValue) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue (Ensure Lockout Threshold is not 0)"
                Write-Host $FailMsg -ForegroundColor Red
                                $Status = "NON-COMPLIANT"
            }
        } else {
            throw "Net accounts command failed with exit code $($Proc.ExitCode)"
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