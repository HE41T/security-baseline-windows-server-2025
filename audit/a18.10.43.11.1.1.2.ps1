# ==============================================================
# CIS Check: 18.10.43.11.1.1.2 (L1) - Audit Script
# Description: Ensure 'Configure Remote Encryption Protection Mode' (Brute-Force Protection) is set to 'Enabled: Audit' (2) or 'Block' (1)
# Registry Path: HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation\Behavioral Network Blocks\Brute Force Protection\BruteForceProtectionConfiguredState
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation\Behavioral Network Blocks\Brute Force Protection"
$ValueName = "BruteForceProtectionConfiguredState"

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.11.1.1.2: Check Brute-Force Protection State"
Write-Host "=============================================================="

function Get-BruteForceProtValue {
    try {
        if (-not (Test-Path -Path $RegPath)) {
            return $null
        }
        $Value = Get-ItemPropertyValue -Path $RegPath -Name $ValueName -ErrorAction Stop
        return [int]$Value
    } catch {
        return $null
    }
}

$CurrentValue = Get-BruteForceProtValue

if ($null -eq $CurrentValue) {
    Write-Host "[!] Value is NOT configured." -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}
elseif ($CurrentValue -eq 1 -or $CurrentValue -eq 2) {
    $Mode = if ($CurrentValue -eq 1) { "Block" } else { "Audit" }
    Write-Host "Value is Compliant ($CurrentValue - $Mode)." -ForegroundColor Green
    $Status = "COMPLIANT"
}
else {
    Write-Host "Value is incorrect ($CurrentValue). Expected 1 (Block) or 2 (Audit)." -ForegroundColor Red
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }