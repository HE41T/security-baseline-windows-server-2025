# ==============================================================
# CIS Check: 2.2.8 (L1) - Audit Script (Fixed Encoding & Null Check)
# Description: Ensure 'Allow log on locally' is set to 'Administrators' (MS only) (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Desired Value: Administrators (S-1-5-32-544)
$DesiredSids = @("S-1-5-32-544")

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.2.8: Ensure 'Allow log on locally' is set to 'Administrators' (MS only) (Automated)"
Write-Host "=============================================================="

$Privilege = "SeInteractiveLogonRight"
$TempFile = [System.IO.Path]::GetTempFileName()

try {
    # 1. Export current rights
    secedit /export /cfg $TempFile /areas USER_RIGHTS | Out-Null
    
    # รอสักครู่เพื่อให้ไฟล์เขียนเสร็จสมบูรณ์ (ป้องกัน Race Condition)
    Start-Sleep -Milliseconds 500
    
    # 2. Robust Parsing (Fix: Force Unicode Read)
    # Secedit exports as Unicode (UTF-16LE). We must read it correctly.
    if (Get-Command Get-Content -ErrorAction SilentlyContinue) {
        $Content = Get-Content $TempFile -Encoding Unicode
    } else {
        # Fallback for very old systems
        $Content = Get-Content $TempFile
    }

    # ค้นหาบรรทัดที่ต้องการ
    $LineObj = $Content | Select-String -Pattern "^\s*$Privilege\s*="
    
    $CurrentSids = @()
    
    if ($LineObj) {
        # แปลงเป็น String ให้ชัวร์ แล้วตัดส่วนหัวทิ้ง
        $ValStr = $LineObj.ToString() -replace "^\s*$Privilege\s*=\s*", ""
        
        # Clean data: ตัด , ตัดช่องว่าง และตัด * ออก
        if (-not [string]::IsNullOrWhiteSpace($ValStr)) {
            $CurrentSids = $ValStr -split "," | ForEach-Object { $_.Trim().TrimStart('*') } | Where-Object { $_ -ne "" }
        }
    }
    
    # 3. Safety Check: Ensure array is not null before comparison
    if ($null -eq $CurrentSids) { $CurrentSids = @() }

    Write-Host "Current Setting (SID): $($CurrentSids -join ', ')"
    Write-Host "Desired Setting (SID): $($DesiredSids -join ', ')"
    
    # 4. Compare Arrays
    $Diff = Compare-Object -ReferenceObject ($DesiredSids | Sort-Object) -DifferenceObject ($CurrentSids | Sort-Object) -SyncWindow 0
    
    if ($null -eq $Diff) {
        Write-Host "Status: COMPLIANT" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Status: NON-COMPLIANT" -ForegroundColor Red
        Write-Host "Difference detected: Users other than Administrators have logon rights or Administrators missing."
        $Status = "NON-COMPLIANT"
    }

} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
} finally {
    if (Test-Path $TempFile) { Remove-Item $TempFile -ErrorAction SilentlyContinue }
}

Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }