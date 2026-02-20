# ==============================================================
# CIS Check: 2.3.11.6 (L1) - Remediation Script
# Description: Ensure 'Network security: Force logoff when logon hours expire' is set to 'Enabled'
# Policy Value: 'enabled' (ForceLogoffWhenHourExpire = 1)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$StartMsg = "Remediation started: $Date"
Write-Host "=============================================================="
Write-Host $StartMsg
Write-Host "Control 2.3.11.6: Force logoff when logon hours expire"
Write-Host "=============================================================="

try {
    # 1. Update Registry (for consistency)
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
    $RegName = "enableforcedlogoff"
    
    if (-not (Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
    Set-ItemProperty -Path $RegPath -Name $RegName -Value 1 -Type DWORD -Force

    # 2. Update Local Security Policy via Secedit
    $ExportPath = "$env:TEMP\secpol.cfg"
    $DbPath = "$env:TEMP\secpol.sdb"

    # Export current local security policy
    secedit.exe /export /cfg $ExportPath | Out-Null

    if (Test-Path $ExportPath) {
        $Content = Get-Content $ExportPath
        $TargetValue = "ForceLogoffWhenHourExpire = 1"
        $Pattern = "^\s*ForceLogoffWhenHourExpire\s*=\s*\d+"
        
        $NewContent = @()
        $MatchFound = $false

        foreach ($Line in $Content) {
            if ($Line -match $Pattern) {
                $NewContent += $TargetValue
                $MatchFound = $true
            } else {
                $NewContent += $Line
            }
        }

        # If it doesn't exist, append it under [System Access] section
        if (-not $MatchFound) {
            $SystemAccessIndex = -1
            for ($i = 0; $i -lt $NewContent.Count; $i++) {
                if ($NewContent[$i] -match "\[System Access\]") {
                    $SystemAccessIndex = $i
                    break
                }
            }
            
            if ($SystemAccessIndex -ge 0) {
                $NewArray = @()
                for ($i = 0; $i -lt $NewContent.Count; $i++) {
                    $NewArray += $NewContent[$i]
                    if ($i -eq $SystemAccessIndex) {
                        $NewArray += $TargetValue
                    }
                }
                $NewContent = $NewArray
            } else {
                $NewContent += "[System Access]"
                $NewContent += $TargetValue
            }
        }

        # Save the modified policy (Must use Unicode encoding for Secedit to read it properly)
        Set-Content -Path $ExportPath -Value $NewContent -Encoding Unicode
        
        # Apply the updated policy back to the system
        secedit.exe /configure /db $DbPath /cfg $ExportPath /areas SECURITYPOLICY | Out-Null

        # Cleanup temporary files
        if (Test-Path $ExportPath) { Remove-Item $ExportPath -Force }
        if (Test-Path $DbPath) { Remove-Item $DbPath -Force }

        $Msg = "Fixed. Set ForceLogoffWhenHourExpire to 1 via Secedit."
        Write-Host $Msg -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Failed to export security policy via secedit." -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }

} catch {
    $Msg = "Error: $_"
    Write-Host $Msg -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Remediation completed at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
Write-Host "Final Status: $Status"
Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }