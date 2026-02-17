# ==============================================================
# CIS Check: 2.3.11.6 (L1) - Remediation Script
# Description: Force logoff when logon hours expire
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_2_3_11_6.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.11.6: Force logoff when logon hours expire"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"


try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
    $RegName = "ForceLogoffWhenHourExpire"
    $TargetValue = 1
    
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $TargetValue -Type DWORD -Force
    
    # Verify
    $NewVal = (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue).$RegName
    if ($NewVal -eq $TargetValue) {
        $Msg = "Fixed. Set $RegName to $NewVal"
        Write-Host $Msg -ForegroundColor Green
        Add-Content -Path $LogFile -Value $Msg
        $Status = "COMPLIANT"
    } else {
        $Msg = "Failed to set registry value."
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
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
