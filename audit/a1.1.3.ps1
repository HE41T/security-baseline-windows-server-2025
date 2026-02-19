# ==============================================================
# CIS Check: 1.1.3 (L1) - Audit Script
# Description: Ensure 'Minimum password age' is set to '1 or more day(s)' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1 # Minimum required value (days)

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.1.3: Ensure 'Minimum password age' is >= $DesiredValue day(s)"
Write-Host "=============================================================="

# ตรวจสอบค่าโดยใช้ net accounts
try {
    $NetOutput = net accounts | Select-String "Minimum password age"
    
    if ($NetOutput) {
        # ดึงเฉพาะตัวเลขออกมา
        $ValueString = ($NetOutput.ToString() -split ":")[1].Trim()
        $CurrentValue = [int]($ValueString -replace "[^0-9]", "")
    } else {
        throw "Could not parse 'net accounts' output."
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
elseif ($CurrentValue -ge $DesiredValue) {
    # กรณีค่าถูกต้อง (>= 1)
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    # กรณีค่าไม่ถูกต้อง (เช่น 0)
    Write-Host "Value is incorrect ($CurrentValue). Expected: >= $DesiredValue" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }