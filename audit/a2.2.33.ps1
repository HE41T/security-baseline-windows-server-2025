# ==============================================================
# CIS Check: 2.2.33 (L1) - Audit Script (Standardized)
# Description: Ensure 'Impersonate a client after authentication' is set to 'Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE' and (when the Web Server (IIS) Role with Web Services Role Service is installed) 'IIS_IUSRS' (MS only) (Automated)
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Desired: Admins, Local Service, Network Service, Service, IIS_IUSRS
$DesiredSids = @("S-1-5-32-544", "S-1-5-19", "S-1-5-20", "S-1-5-6", "S-1-5-32-568")

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 2.2.33: Impersonate a client after authentication"
Write-Host "=============================================================="

$Privilege = "SeImpersonatePrivilege"
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
    
    # Note: For this control, it's often okay if fewer SIDs exist, but usually we check for exact match or specific subset.
    # CIS Logic: "The recommended state... includes only the following..." -> Exact Match
    $Diff = Compare-Object -ReferenceObject ($DesiredSids | Sort-Object) -DifferenceObject ($CurrentSids | Sort-Object) -SyncWindow 0
    
    if ($null -eq $Diff) {
        Write-Host "Status: COMPLIANT" -ForegroundColor Green
        $Status = "COMPLIANT"
    } else {
        # Optional: Allow slight flexibility if needed, but for Strict compliance:
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