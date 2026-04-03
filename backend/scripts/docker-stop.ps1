Set-Location (Split-Path $PSScriptRoot -Parent)
docker-compose down
Write-Host 'Container durduruldu.' -ForegroundColor Cyan