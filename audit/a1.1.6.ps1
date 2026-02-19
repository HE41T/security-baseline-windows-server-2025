# ==============================================================
# CIS Check: 1.1.6 (L1) - Audit Script
# Description: Ensure 'Relax minimum password length limits' is set to 'Enabled' (Automated)
# Registry: HKLM\SYSTEM\CurrentControlSet\Control\SAM -> RelaxMinimumPasswordLengthLimits = 1
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1 # Enabled

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.1.6: Ensure 'Relax minimum password length limits' is Enabled"
Write-Host "=============================================================="

try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SAM"
    $RegName = "RelaxMinimumPasswordLengthLimits"
    
    $Item = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    
    if ($Item) {
        $CurrentValue = $Item.$RegName
    } else {
        $CurrentValue = $null # Not Set / Disabled implicitly
    }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving registry: $_" -ForegroundColor Red
}

if ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    # If null, show 0 or Not Set
    $ShowVal = if ($null -eq $CurrentValue) { "Not Set (Disabled)" } else { $CurrentValue }
    Write-Host "Value is incorrect ($ShowVal). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }