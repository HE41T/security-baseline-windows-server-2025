# ==============================================================
# CIS Check: 2.2.11 (L1) - Audit Script (Standardized)
# Description: Ensure 'Back up files and directories' is set to 'Administrators' (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Desired Value: Administrators (S-1-5-32-544)
$DesiredSids = @("S-1-5-32-544")

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.2.11: Ensure 'Back up files and directories' is set to 'Administrators' (Automated)"
Write-Host "=============================================================="

$Privilege = "SeBackupPrivilege"
$TempFile = [System.IO.Path]::GetTempFileName()

try {
    # 1. Export
    secedit /export /cfg $TempFile /areas USER_RIGHTS | Out-Null
    Start-Sleep -Milliseconds 500
    
    # 2. Robust Parsing (Unicode)
    if (Get-Command Get-Content -ErrorAction SilentlyContinue) {
        $Content = Get-Content $TempFile -Encoding Unicode
    } else {
        $Content = Get-Content $TempFile
    }
    
    $LineObj = $Content | Select-String -Pattern "^\s*$Privilege\s*="
    $CurrentSids = @()
    
    if ($LineObj) {
        $ValStr = $LineObj.ToString() -replace "^\s*$Privilege\s*=\s*", ""
        if (-not [string]::IsNullOrWhiteSpace($ValStr)) {
            # Trim * to match remediation logic
            $CurrentSids = $ValStr -split "," | ForEach-Object { $_.Trim().TrimStart('*') } | Where-Object { $_ -ne "" }
        }
    }
    
    if ($null -eq $CurrentSids) { $CurrentSids = @() }

    Write-Host "Current Setting (SID): $($CurrentSids -join ', ')"
    Write-Host "Desired Setting (SID): $($DesiredSids -join ', ')"
    
    # 3. Compare
    $Diff = Compare-Object -ReferenceObject ($DesiredSids | Sort-Object) -DifferenceObject ($CurrentSids | Sort-Object) -SyncWindow 0
    
    if ($null -eq $Diff) {
        Write-Host "Status: COMPLIANT" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        Write-Host "Status: NON-COMPLIANT" -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }

} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
    $Status = "NON-COMPLIANT"
} finally {
    if (Test-Path $TempFile) { Remove-Item $TempFile -ErrorAction SilentlyContinue }
}

Write-Host "=============================================================="
if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }