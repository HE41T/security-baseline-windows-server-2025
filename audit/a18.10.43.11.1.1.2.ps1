# ==============================================================
# CIS Check: 18.10.43.11.1.1.2 (L1) - Audit Script
# Description: Ensure 'Configure Remote Encryption Protection Mode' is set to 'Enabled: Audit' or higher (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Subcategory = "Configure Remote Encryption Protection Mode"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.11.1.1.2: Ensure '$Subcategory' Success and Failure auditing are enabled"
Write-Host "=============================================================="

function Get-AuditValues {
    $result = @{}
    try {
        $output = auditpol /get /subcategory:"$Subcategory" 2>$null
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        foreach ($line in $output) {
            $successMatch = [regex]::Match($line, 'Success\s*:\s*(\w+)')
            if ($successMatch.Success) {
                $result.Success = $successMatch.Groups[1].Value
            }
            $failureMatch = [regex]::Match($line, 'Failure\s*:\s*(\w+)')
            if ($failureMatch.Success) {
                $result.Failure = $failureMatch.Groups[1].Value
            }
        }
    } catch {
        return $null
    }
    return $result
}

$Status = "NON-COMPLIANT"
$Values = Get-AuditValues
if ($null -eq $Values -or -not $Values.Success -or -not $Values.Failure) {
    Write-Host "Unable to retrieve audit settings for '$Subcategory'." -ForegroundColor Yellow
} elseif ($Values.Success.Trim().ToLower() -eq "enable" -and $Values.Failure.Trim().ToLower() -eq "enable") {
    Write-Host "Success and Failure auditing are both set to Enable." -ForegroundColor Green
    $Status = "COMPLIANT"
} else {
    Write-Host "Current settings do not both equal Enable (Success: $($Values.Success); Failure: $($Values.Failure))." -ForegroundColor Red
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
