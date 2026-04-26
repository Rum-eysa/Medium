# Production build ve calistirma
Set-Location (Split-Path $PSScriptRoot -Parent)
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
Write-Host 'API calisiyor: http://localhost:8000' -ForegroundColor Green