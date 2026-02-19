# ==============================================================
# CIS Check: 2.3.7.4 (L1) - Remediation Script
# Description: Configure 'Interactive logon: Message text for users attempting to log on' (Automated)
# ==============================================================

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


try {
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type String -Force
    
    $Verify = (Get-ItemProperty -Path $RegPath).$RegName
    
    if ($Verify -eq $DesiredValue) {
        $Msg = "Success: Value set to '$Verify'"
        Write-Host $Msg -ForegroundColor Green
                $Status = "COMPLIANT"
    } else {
        $Msg = "Failed: Value read back as '$Verify'"
        Write-Host $Msg -ForegroundColor Red
                $Status = "NON-COMPLIANT"
    }
} catch {
    $Msg = "Error: $_"
    Write-Host $Msg -ForegroundColor Red
        $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }