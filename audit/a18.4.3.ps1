# ==============================================================
# CIS Check: 18.4.3 (L1) - Audit Script
# Description: Ensure 'Configure SMB v1 server' is set to 'Disabled'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 0 # 0 = Disabled
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$RegName = "SMB1"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.4.3: Ensure SMB v1 server is Disabled ($DesiredValue)"
Write-Host "=============================================================="

try {
    $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($RegData -and $RegData.$RegName -ne $null) {
        $CurrentValue = [int]$RegData.$RegName
    } else {
        # ถ้าไม่มี Key โดยปกติ Windows รุ่นใหม่จะ Disabled โดย Default แต่ CIS บังคับให้สร้าง
        $CurrentValue = -1 
    }
} catch {
    $CurrentValue = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

# เริ่มตรวจสอบเงื่อนไข
if ($null -eq $CurrentValue) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    $ShowVal = if ($CurrentValue -eq -1) { "Not Configured" } else { $CurrentValue }
    Write-Host "Value is incorrect ($ShowVal). Expected: $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }