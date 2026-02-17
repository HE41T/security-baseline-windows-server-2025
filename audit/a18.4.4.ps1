# ==============================================================
# CIS Check: 18.4.4 (L1) - Audit Script
# Description: Ensure 'Enable Certificate Padding' is set to 'Enabled'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "1" # Note: Key นี้มักจะเป็น String
$RegPath = "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config"
$RegName = "EnableCertPaddingCheck"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.4.4: Ensure Certificate Padding is Enabled ($DesiredValue)"
Write-Host "=============================================================="

try {
    $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($RegData -and $RegData.$RegName -ne $null) {
        $CurrentValue = [string]$RegData.$RegName
    } else { $CurrentValue = "-1" }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    $ShowVal = if ($CurrentValue -eq "-1") { "Not Configured" } else { $CurrentValue }
    Write-Host "Value is incorrect ($ShowVal). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }