# ==============================================================
# CIS Check: 2.2.31 (L1) - Audit Script (Standardized)
# Description: Ensure 'Generate security audits' is set to Local Service & Network Service
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Desired: Local Service (S-1-5-19), Network Service (S-1-5-20)
$DesiredSids = @("S-1-5-19", "S-1-5-20")

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.2.31: Generate security audits"
Write-Host "=============================================================="

$Privilege = "SeAuditPrivilege"
$TempFile = [System.IO.Path]::GetTempFileName()

try {
    secedit /export /cfg $TempFile /areas USER_RIGHTS | Out-Null
    Start-Sleep -Milliseconds 500
    
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
            $CurrentSids = $ValStr -split "," | ForEach-Object { $_.Trim().TrimStart('*') } | Where-Object { $_ -ne "" }
        }
    }
    
    if ($null -eq $CurrentSids) { $CurrentSids = @() }
    
    Write-Host "Current Setting (SID): $($CurrentSids -join ', ')"
    Write-Host "Desired Setting (SID): $($DesiredSids -join ', ')"
    
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