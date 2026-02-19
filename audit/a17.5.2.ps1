# ==============================================================
# CIS Check: 17.5.2 (L1) - Audit Script
# Description: Ensure 'Audit Group Membership' is set to include 'Success' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "Enabled"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 17.5.2: Audit Group Membership"
Write-Host "=============================================================="


$Subcat = "Group Membership"
try {
    $Result = auditpol /get /subcategory:"$Subcat" /r | ConvertFrom-Csv
    if ($Result) {
        $CurrSuccess = $Result.'Inclusion Setting' -match "Success"
        $CurrFailure = $Result.'Inclusion Setting' -match "Failure"
        
        Write-Host "Current: $($Result.'Inclusion Setting')"
        
        # Check requirements
        $ReqSuccess = $true # Simplified for template
        $ReqFailure = $true
        
        if ("Enable" -eq "Disable") { $ReqSuccess = $false }
        if ("Disable" -eq "Disable") { $ReqFailure = $false }
        
        # Logic matches?
        if (($CurrSuccess -eq $ReqSuccess) -and ($CurrFailure -eq $ReqFailure)) {
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
