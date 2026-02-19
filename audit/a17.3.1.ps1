# ==============================================================
# CIS Check: 17.3.1 (L1) - Audit Script
# Description: Ensure 'Audit PNP Activity' is set to include 'Success'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 17.3.1: Ensure 'Audit PNP Activity' is set to include 'Success'"
Write-Host "=============================================================="

# Using the exact GUID prescribed in the CIS Audit Procedure
$Subcat = "{0cce9248-69ae-11d9-bed3-505054503030}"

try {
    $Result = auditpol /get /subcategory:"$Subcat" /r | ConvertFrom-Csv
    if ($Result) {
        $CurrSuccess = $Result.'Inclusion Setting' -match "Success"
        $CurrFailure = $Result.'Inclusion Setting' -match "Failure"
        
        Write-Host "Current: $($Result.'Inclusion Setting')"
        
        # Policy Value requires 'success' OR 'success, failure'.
        # We only strictly require Success to be enabled.
        $ReqSuccess = $true
        
        # Logic matches?
        if ($CurrSuccess -eq $ReqSuccess) {
             Write-Host "Compliant" -ForegroundColor Green
             $Status = "COMPLIANT"
        } else {
             Write-Host "Non-Compliant" -ForegroundColor Red
             $Status = "NON-COMPLIANT"
        }
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Action completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }