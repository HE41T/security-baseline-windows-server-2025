# ==============================================================
# CIS Check: 2.2.3 (L1) - Remediation Script
# Description: Ensure 'Access this computer from the network' is set to 'Administrators, Authenticated Users'
# ==============================================================

$LogFile = "C:\Windows\Temp\remediate_network_access.log"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# SID เป้าหมาย: Administrators, Authenticated Users
$DesiredSIDs = @("*S-1-5-32-544", "*S-1-5-11")
$DesiredString = "*S-1-5-32-544,*S-1-5-11"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.2.3: Ensure 'Access this computer from the network' is set correctly"
Write-Host "=============================================================="

Add-Content -Path $LogFile -Value "`n=============================================================="
Add-Content -Path $LogFile -Value "$StartMsg"

# 1. ฟังก์ชันสำหรับอ่านค่าปัจจุบัน (Reusable)
function Get-NetworkLogonRight {
    $TempInf = "$env:TEMP\secpol_check_2.2.3.inf"
    try {
        Start-Process -FilePath "secedit.exe" -ArgumentList "/export /cfg `"$TempInf`" /areas USER_RIGHTS" -Wait -NoNewWindow
        
        if (Test-Path $TempInf) {
            $Content = Get-Content $TempInf
            $Line = $Content | Select-String -Pattern "^SeNetworkLogonRight\s*="
            
            if ($Line) {
                $Raw = ($Line.ToString() -split "=")[1].Trim()
                $SIDs = $Raw -split "," | ForEach-Object { $_.Trim() }
            } else {
                $SIDs = @()
            }
            Remove-Item $TempInf -Force
            return $SIDs
        }
        return $null
    } catch {
        return $null
    }
}

# ตรวจสอบค่าก่อนแก้ไข
$CurrentSIDs = Get-NetworkLogonRight

# Prepare logic for comparison
$SortedCurrent = $CurrentSIDs | Sort-Object
$SortedDesired = $DesiredSIDs | Sort-Object
$IsMatch = ($SortedCurrent -join ",") -eq ($SortedDesired -join ",")

if ($null -eq $CurrentSIDs) {
    $Msg = "[!] Error: Could not read current policy."
    Write-Host $Msg -ForegroundColor Red
    Add-Content -Path $LogFile -Value $Msg
    $Status = "NON-COMPLIANT"
}
elseif (-not $IsMatch) {
    $Msg = "Value is incorrect. Current: $($SortedCurrent -join ", "). Fixing..."
    Write-Host $Msg -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value $Msg
    
    try {
        # สร้างไฟล์ .inf สำหรับ Configure
        $FixInf = "$env:TEMP\remediate_2.2.3.inf"
        $InfContent = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeNetworkLogonRight = $DesiredString
"@
        Set-Content -Path $FixInf -Value $InfContent -Encoding Unicode

        # สั่ง secedit ให้ Apply ค่าจากไฟล์ .inf
        $Proc = Start-Process -FilePath "secedit.exe" -ArgumentList "/configure /db secedit.sdb /cfg `"$FixInf`" /areas USER_RIGHTS" -Wait -NoNewWindow -PassThru
        
        if ($Proc.ExitCode -eq 0) {
            # ลบไฟล์ temp
            Remove-Item $FixInf -Force

            # ตรวจสอบซ้ำ (Verify)
            $NewSIDs = Get-NetworkLogonRight
            $SortedNew = $NewSIDs | Sort-Object
            
            if (($SortedNew -join ",") -eq ($SortedDesired -join ",")) {
                $ResultMsg = "Fixed. New configuration applied."
                Write-Host $ResultMsg -ForegroundColor Green
                Add-Content -Path $LogFile -Value $ResultMsg
                $Status = "COMPLIANT"
            } else {
                $FailMsg = "Verification failed. Value remains: $($SortedNew -join ", ")"
                Write-Host $FailMsg -ForegroundColor Red
                Add-Content -Path $LogFile -Value $FailMsg
                $Status = "NON-COMPLIANT"
            }
        } else {
            throw "Secedit command failed with exit code $($Proc.ExitCode)"
        }
        
    } catch {
        $ErrorMsg = "Failed to fix: $_"
        Write-Host $ErrorMsg -ForegroundColor Red
        Add-Content -Path $LogFile -Value $ErrorMsg
        $Status = "NON-COMPLIANT"
    }

} else {
    $Msg = "Value is correct. No action needed."
    Write-Host $Msg -ForegroundColor Green
    Add-Content -Path $LogFile -Value $Msg
    $Status = "COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date)"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
Add-Content -Path $LogFile -Value "Final Status: $Status"
Add-Content -Path $LogFile -Value "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }