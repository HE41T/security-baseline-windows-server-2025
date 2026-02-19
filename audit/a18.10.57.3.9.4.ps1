# ==============================================================
# CIS Check: 18.10.57.3.9.4 (L1) - Audit Script
# Description: Ensure 'Require user authentication for remote connections by using Network Level Authentication' is set to 'Enabled'
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\UserAuthentication
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 1
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$ValueName = "UserAuthentication"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.57.3.9.4: Check Network Level Authentication (NLA)"
Write-Host "=============================================================="

function Get-NLAValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return $null
    }
}

$CurrentValue = Get-NLAValue

if ($null -eq $CurrentValue) {
    # สำหรับ Windows Server รุ่นใหม่ๆ Default เป็น Enabled แต่อาจไม่มีค่า Registry ตายตัวถ้าไม่ได้ตั้ง GPO
    Write-Host "[!] Value is NOT configured via GPO (Default behavior varies by OS version)." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq $DesiredValue) {
    Write-Host "Value is Compliant ($CurrentValue - NLA is Required)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). NLA is NOT enforced!" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }