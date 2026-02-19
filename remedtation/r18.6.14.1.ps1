# ==============================================================
# CIS Check: 18.6.14.1 (L1) - Remediation Script
# Description: Ensure Hardened UNC Paths for NETLOGON and SYSVOL
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
$PathsToHarden = @("\\*\NETLOGON", "\\*\SYSVOL")
$DesiredValue = "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1"

Write-Host "=============================================================="
Write-Host "Remediation started: $Date"
Write-Host "Control 18.6.14.1: Hardening UNC Paths (NETLOGON & SYSVOL)"
Write-Host "=============================================================="

$GlobalStatus = "COMPLIANT"

foreach ($PathName in $PathsToHarden) {
    Write-Host "Checking: $PathName" -NoNewline
    
    # 1. ตรวจสอบค่าปัจจุบัน
    $CurrentValue = (Get-ItemProperty -Path $RegPath -Name $PathName -ErrorAction SilentlyContinue).$PathName
    
    if ($null -eq $CurrentValue -or $CurrentValue -ne $DesiredValue) {
        Write-Host " -> [INCORRECT]" -ForegroundColor Yellow
        Write-Host "Fixing $PathName..." -ForegroundColor Cyan
        
        try {
            if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
            Set-ItemProperty -Path $RegPath -Name $PathName -Value $DesiredValue -Type String -Force
            
            # ตรวจสอบซ้ำหลังแก้
            $Verify = (Get-ItemProperty -Path $RegPath -Name $PathName -ErrorAction SilentlyContinue).$PathName
            if ($Verify -eq $DesiredValue) {
                Write-Host "Successfully fixed: $PathName" -ForegroundColor Green
            } else {
                Write-Host "Failed to fix: $PathName" -ForegroundColor Red
                $GlobalStatus = "NON-COMPLIANT"
            }
        } catch {
            Write-Host "Error: $_" -ForegroundColor Red
            $GlobalStatus = "NON-COMPLIANT"
        }
    } else {
        Write-Host " -> [OK]" -ForegroundColor Green
    }
}

Write-Host "=============================================================="
Write-Host "Final Status: $GlobalStatus"
Write-Host "=============================================================="

if ($GlobalStatus -eq "COMPLIANT") { exit 0 } else { exit 1 }