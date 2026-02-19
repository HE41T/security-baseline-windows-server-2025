# ==============================================================
# CIS Check: 18.6.14.1 (L1) - Audit Script
# Description: Ensure Hardened UNC Paths for NETLOGON and SYSVOL
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
$PathsToHarden = @("\\*\NETLOGON", "\\*\SYSVOL")
$DesiredValue = "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.6.14.1: Hardening UNC Paths (NETLOGON & SYSVOL)"
Write-Host "=============================================================="

$Status = "COMPLIANT"

# วนลูปตรวจสอบทั้ง 2 Path (NETLOGON และ SYSVOL)
foreach ($PathName in $PathsToHarden) {
    $RegData = Get-ItemProperty -Path $RegPath -Name $PathName -ErrorAction SilentlyContinue
    
    # ดึงค่าออกมา ถ้าไม่มีให้เป็น $null
    $CurrentValue = if ($null -ne $RegData -and $null -ne $RegData.$PathName) { $RegData.$PathName } else { $null }

    if ($CurrentValue -ne $DesiredValue) {
        $ShowVal = if ($null -eq $CurrentValue) { "Not Configured" } else { $CurrentValue }
        Write-Host "[!] $PathName is Incorrect or Missing ($ShowVal)" -ForegroundColor Red
        
        # ถ้าเจอตัวใดตัวหนึ่งผิด ให้ปรับ Status รวมเป็น NON-COMPLIANT ทันที
        $Status = "NON-COMPLIANT"
    } else {
        Write-Host "[OK] $PathName is Correct" -ForegroundColor Green
    }
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }