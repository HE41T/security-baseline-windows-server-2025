# ==============================================================
# CIS Check: 18.10.43.11.1.1.2 (L1) - Remediation Script
# Description: Ensure 'Configure Remote Encryption Protection Mode' is set to 'Enabled: Audit' or higher (Automated)
# ==============================================================

$Subcategory = "Configure Remote Encryption Protection Mode"
$LogFile = "C:\Windows\Temp\remediate_18_10_43_11_1_1_2.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.10.43.11.1.1.2: Ensure '$Subcategory' auditing is enabled"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value $StartMsg

function Get-AuditValues {
    $result = @{}
    try {
        $output = auditpol /get /subcategory:"$Subcategory" 2>$null
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        foreach ($line in $output) {
            $sm = [regex]::Match($line, 'Success\s*:\s*(\w+)')
            if ($sm.Success) {
                $result.Success = $sm.Groups[1].Value
            }
            $fm = [regex]::Match($line, 'Failure\s*:\s*(\w+)')
            if ($fm.Success) {
                $result.Failure = $fm.Groups[1].Value
            }
        }
    } catch {
        return $null
    }
    return $result
}

function Set-AuditValues {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    if (-not $PSCmdlet.ShouldProcess($Subcategory, "Enable success and failure auditing")) {
        return
    }
    & auditpol /set /subcategory:"$Subcategory" /success:enable /failure:enable | Out-Null
}

$Values = Get-AuditValues

if ($null -ne $Values -and $Values.Success.Trim().ToLower() -eq "enable" -and $Values.Failure.Trim().ToLower() -eq "enable") {
    $Msg = "Success and Failure auditing are already enabled."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
} else {
    $Msg = "Applying audit settings: success=enable, failure=enable."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    try {
        Set-AuditValues
        Start-Sleep -Seconds 1
        $NewValues = Get-AuditValues
        if ($null -ne $NewValues -and $NewValues.Success.Trim().ToLower() -eq "enable" -and $NewValues.Failure.Trim().ToLower() -eq "enable") {
            $ResultMsg = "Fixed. Success=$($NewValues.Success); Failure=$($NewValues.Failure)."
            Write-Host $ResultMsg -ForegroundColor Green
            Add-Content -Path $LogFile -Value $ResultMsg
            $Status = "COMPLIANT"
        } else {
            $FailMsg = "Verification failed. Current values: Success=$($NewValues.Success); Failure=$($NewValues.Failure)."
            Write-Host $FailMsg -ForegroundColor Red
            Add-Content -Path $LogFile -Value $FailMsg
            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to set audit values: $_"
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
