# ==============================================================
# CIS Check: 18.4.2 (L1) - Remediation Script
# Description: Ensure 'Configure SMB v1 client driver' is set to 'Enabled: Disable driver'
# ==============================================================


$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$DesiredValue = 4
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10"
$RegName = "Start"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 18.4.2: Ensure SMB v1 client driver is Disabled ($DesiredValue)"
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
        
        # 1. แก้ไขใน Registry
        Set-ItemProperty -Path $RegPath -Name $RegName -Value $DesiredValue -Type DWord -Force
        
        # 2. ปิด Windows Feature เพิ่มเติม (เพื่อความชัวร์)
        $Feat = Get-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol"
        if ($Feat.State -ne "Disabled") {
            Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart | Out-Null
            
        }

        # ตรวจสอบซ้ำ (Verify Registry)
        $NewValue = Get-RegistryValue
        if ($NewValue -eq $DesiredValue) {
            $ResultMsg = "Fixed. New value is $NewValue (Reboot Required)."
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