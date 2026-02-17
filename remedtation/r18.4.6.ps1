# ==============================================================
# CIS Check: 18.4.6 (L1) - Remediation Script
# Description: Ensure 'NetBT NodeType configuration' is set to 'P-node'
# ==============================================================


$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 2
$RegPath = "HKLM:\System\CurrentControlSet\Services\NetBT\Parameters"
$RegName = "NodeType"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.4.6: Ensure NetBT NodeType is P-node ($DesiredValue)"
Write-Host "=============================================================="

function Get-RegistryValue {
    try {
        $RegData = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        if ($RegData -and $RegData.$RegName -ne $null) { return [int]$RegData.$RegName }
        return -1
    } catch { return -1 }
}

$CurrentValue = Get-RegistryValue

if ($CurrentValue -eq -1 -or $CurrentValue -ne $DesiredValue) {
    $Msg = "Value is incorrect or missing ($CurrentValue). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    
    try {
        if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type DWord -Force
        
        $NewValue = Get-RegistryValue
        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Fixed. New value is $NewValue."
            Write-Host $ResultMsg -ForegroundColor Green

            $Status = "COMPLIANT"
        } else {
            $FailMsg = "Verification failed. Value remains $NewValue"
            Write-Host $FailMsg -ForegroundColor Red

            $Status = "NON-COMPLIANT"
        }
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red

        $Status = "NON-COMPLIANT"
    }
} else {
    $Msg = "Value is correct ($CurrentValue). No action needed."
    Write-Host $Msg -ForegroundColor Green

    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="


if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }