# ==============================================================
# CIS Check: 1.2.2 (L1) - Remediation Script
# Description: Ensure 'Account lockout threshold' is set to '5 or fewer invalid logon attempt(s), but not 0' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$TargetValue = 5 # Setting to 5 (Compliant range 1-5)

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 1.2.2: Ensure 'Account lockout threshold' is <= 5 and > 0"
Write-Host "=============================================================="


function Get-LockoutThreshold {
    try {
        $NetOutput = net accounts | Select-String "Lockout threshold"
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

$CurrentValue = Get-LockoutThreshold

# Condition: <= 5 AND > 0
if ($CurrentValue -le 5 -and $CurrentValue -gt 0) {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
} else {
    $Msg = "Value is incorrect ($CurrentValue). Fixing to $TargetValue..."
    Write-Host $Msg -ForegroundColor Yellow
        
    try {
        $Proc = Start-Process "net.exe" -ArgumentList "accounts /lockoutthreshold:$TargetValue" -NoNewWindow -Wait -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            $NewValue = Get-LockoutThreshold
            if ($NewValue -le 5 -and $NewValue -gt 0) {
                $ResultMsg = "Fixed. New value is $NewValue."
                Write-Host $ResultMsg -ForegroundColor Green
                                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains $NewValue"
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