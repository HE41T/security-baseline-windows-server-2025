# ==============================================================
# CIS Check: 1.1.2 (L1) - Audit Script
# Description: Ensure 'Maximum password age' is set to '365 or fewer days, but not 0' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$MaxDays = 365

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.1.2: Ensure 'Maximum password age' is <= $MaxDays and not 0"
Write-Host "=============================================================="

# ใช้ net accounts เพื่อความเสถียร
try {
    $NetOutput = net accounts | Select-String "Maximum password age"
    
    if ($NetOutput) {
        $ValueString = ($NetOutput.ToString() -split ":")[1].Trim()
        
        if ($ValueString -match "Unlimited") {
            $CurrentValue = 0 
            $IsUnlimited = $true
        } else {
            # แปลงเป็น Int ทันทีเพื่อความชัวร์
            $CurrentValue = [int]($ValueString -replace "[^0-9]", "")
            $IsUnlimited = $false
        }
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
elseif ($IsUnlimited -or $CurrentValue -eq 0) {
    Write-Host "Value is incorrect (Unlimited/0). Expected: 1 to $MaxDays days" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -gt $MaxDays) {
    Write-Host "Value is incorrect ($CurrentValue). Expected: <= $MaxDays days" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
else {
    # ค่าถูกต้อง (1 - 365)
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }