# ==============================================================
# CIS Check: 18.10.43.6.1.2 (L1) - Audit Script
# Description: Ensure 'Configure Attack Surface Reduction rules: Set the state for each ASR rule' is configured (Automated)
# Verification Method: Export USER_RIGHTS via secedit and look for the ASR INF entry
# ==============================================================

$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
$Rules = @(
    "26190899-1602-49e8-8b27-eb1d0a1ce869", "3b576869-a4ec-4529-8536-b80a7769e899",
    "56a863a9-875e-4185-98a7-b882c64b5ce5", "5beb7efe-fd9a-4556-801d-275e5ffc04cc",
    "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84", "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c",
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2", "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4",
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550", "d3e037e1-3eb8-44c8-a917-57927947596d",
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a", "e6db77e5-3df2-4cf1-b95a-636979351e5b"
)

Write-Host "=============================================================="
Write-Host "Audit started: $Date"
Write-Host "Control 18.10.43.6.1.2: Ensure ASR rules are configured"
Write-Host "=============================================================="

$Status = "COMPLIANT"
try {
    if (Test-Path -Path $RegPath) {
        foreach ($Guid in $Rules) {
            $Value = Get-ItemPropertyValue -Path $RegPath -Name $Guid -ErrorAction SilentlyContinue
            if ($null -eq $Value -or $Value -ne "1") {
                Write-Host "Rule '$Guid' is NOT set to Block (current: $Value)." -ForegroundColor Red
                $Status = "NON-COMPLIANT"
            } else {
                Write-Host "Rule '$Guid' is set to Block." -ForegroundColor Green
            }
        }
    } else {
        Write-Host "Registry path '$RegPath' was not found." -ForegroundColor Red
        $Status = "NON-COMPLIANT"
    }
} catch {
    Write-Host "[!] Failed to audit ASR rules: $_" -ForegroundColor Yellow
    $Status = "NON-COMPLIANT"
}

Write-Host "=============================================================="
Write-Host "Audit completed at $(Get-Date)"
Write-Host "Status: $Status"
Write-Host "=============================================================="

if ($Status -eq "COMPLIANT") { exit 0 } else { exit 1 }
