# ==============================================================
# CIS Check: 2.2.3 (L1) - Audit Script
# Description: Ensure 'Access this computer from the network' is set to 'Administrators, Authenticated Users' (MS only) (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# SID ที่ถูกต้องตาม CIS (Member Servers):
# *S-1-5-32-544 = Administrators
# *S-1-5-11     = Authenticated Users
$DesiredSIDs = @("*S-1-5-32-544", "*S-1-5-11") 
$DesiredNames = "Administrators, Authenticated Users"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.2.3: Ensure 'Access this computer from the network' is set correctly"
Write-Host "Expected: $DesiredNames"
Write-Host "=============================================================="

$SecEditExport = "$env:TEMP\secpol_audit_2.2.3.inf"

try {
    # 1. Export Security Policy ปัจจุบันไปยัง Temp file
    # /quiet เพื่อไม่ให้แสดง popup, /areas USER_RIGHTS เพื่อดึงเฉพาะสิทธิ์ผู้ใช้
    Start-Process -FilePath "secedit.exe" -ArgumentList "/export /cfg `"$SecEditExport`" /areas USER_RIGHTS" -Wait -NoNewWindow

    # 2. อ่านไฟล์และหาค่า SeNetworkLogonRight
    if (Test-Path $SecEditExport) {
        $Content = Get-Content $SecEditExport
        # ค้นหาบรรทัดที่ขึ้นต้นด้วย SeNetworkLogonRight
        $Line = $Content | Select-String -Pattern "^SeNetworkLogonRight\s*="
        
        if ($Line) {
            # ดึงค่าหลังเครื่องหมาย = และตัดช่องว่าง
            $RawValue = ($Line.ToString() -split "=")[1].Trim()
            
            # แยกค่าด้วยคอมมา (,) กรณีมีหลาย user/group
            $CurrentSIDs = $RawValue -split "," | ForEach-Object { $_.Trim() }
        } else {
            # กรณีไม่มีบรรทัดนี้ แสดงว่าไม่มีใครได้รับสิทธิ์นี้เลย (Empty)
            $CurrentSIDs = @()
        }
    } else {
        throw "Failed to export security policy."
    }

    # Clean up temp file
    if (Test-Path $SecEditExport) { Remove-Item $SecEditExport -Force }

} catch {
    $CurrentSIDs = $null
    Write-Host "[!] Error retrieving policy: $_" -ForegroundColor Red
}

# 3. เริ่มตรวจสอบเงื่อนไข (Compare Arrays)
# เรียงลำดับเพื่อให้เปรียบเทียบได้ถูกต้อง
$SortedCurrent = $CurrentSIDs | Sort-Object
$SortedDesired = $DesiredSIDs | Sort-Object
$CurrentString = $SortedCurrent -join ", "

if ($null -eq $CurrentSIDs) {
    Write-Host "[!] Unable to determine current value." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}
elseif (($SortedCurrent -join ",") -eq ($SortedDesired -join ",")) {
    # ต้องตรงกันเป๊ะๆ ห้ามมี Everyone หรือ Users อื่นปน
    Write-Host "Value is correct." -ForegroundColor Green
    Write-Host "Current SIDs: $CurrentString" -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect." -ForegroundColor Red
    Write-Host "Current SIDs : $CurrentString" -ForegroundColor Yellow
    Write-Host "Expected SIDs: $($SortedDesired -join ", ")" -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }