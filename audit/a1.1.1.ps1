# ==============================================================
# CIS Check: 1.1.1 (L1) - Audit Script
# Description: Ensure 'Enforce password history' is set to '24 or more password(s)'
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 24

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 1.1.1: Ensure 'Enforce password history' is >= $DesiredValue"
Write-Host "=============================================================="

# วิธีใหม่: ใช้ net accounts ซึ่งเสถียรกว่า ADSI
try {
    # รันคำสั่ง net accounts และหาบรรทัด Password history
    $NetOutput = net accounts | Select-String "Length of password history maintained"
    
    if ($NetOutput) {
        # ดึงเฉพาะตัวเลขออกมา (Regex: เอาเฉพาะ 0-9)
        $ValueString = $NetOutput.ToString() -replace "[^0-9]", ""
        
        if ([string]::IsNullOrWhiteSpace($ValueString)) {
            $CurrentValue = 0 # กรณีเป็น None หรือไม่มีตัวเลข
        } else {
            $CurrentValue = [int]$ValueString
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
elseif ($CurrentValue -ge $DesiredValue) {
    Write-Host "Value is correct ($CurrentValue). No action needed." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected: $DesiredValue or more" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }