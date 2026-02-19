# ==============================================================
# CIS Check: 2.3.7.4 (L1) - Remediation Script
# Description: Interactive logon: Message text for users attempting to log on
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_3_7_4.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = "All activities performed on this system will be monitored."
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$RegName = "LegalNoticeText"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.7.4: Interactive logon: Message text"
Write-Host "Required Value: '$DesiredValue'"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

try {
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type String -Force
    
    $Verify = (Get-ItemProperty -Path $RegPath).$RegName
    
    if ($Verify -eq $DesiredValue) {
        $Msg = "Success: Value set to '$Verify'"
        Write-Host $Msg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $Msg
        $Status = "COMPLIANT"
    } else {
        $Msg = "Failed: Value read back as '$Verify'"
        Write-Host $Msg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $Msg
        $Status = "NON-COMPLIANT"
    }
} catch {
    $Msg = "Error: $_"
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }