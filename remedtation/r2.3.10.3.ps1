# ==============================================================
# CIS Check: 2.3.10.3 (L1) - Remediation Script
# Description: Ensure 'Network access: Do not allow anonymous enumeration of SAM accounts and shares' is set to 'Enabled' (MS only) (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.10.3: Do not allow anonymous enumeration of SAM accounts"
Write-Host "=============================================================="



try {
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
    $RegName = "RestrictAnonymousSAM"
    $TargetValue = 1
    
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $TargetValue -Type DWORD -Force
    
    # Verify
    $NewVal = (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue).$RegName
    if ($NewVal -eq $TargetValue) {
        $Msg = "Fixed. Set $RegName to $NewVal"
        Write-Host $Msg -ForegroundColor Green
                $Status = "COMPLIANT"
    } else {
        $Msg = "Failed to set registry value."
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
