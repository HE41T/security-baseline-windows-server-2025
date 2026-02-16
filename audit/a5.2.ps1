$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler"
$name = "Start"
$expected = 4

try {
    if (Test-Path $regPath) {
        $current = (Get-ItemProperty -Path $regPath -Name $name -ErrorAction Stop).$name
        if ($current -eq $expected) {
            Write-Host "PASS: Print Spooler on Member Server is Disabled (4)"
            exit 0
        } else {
            Write-Host "FAIL: Print Spooler on Member Server is $current (Expected 4)"
            exit 1
        }
    } else {
        Write-Host "ERROR: Registry Path not found"
        exit 1
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    exit 1
}