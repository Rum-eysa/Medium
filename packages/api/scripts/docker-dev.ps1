# Docker ile gelistirme ortami (kod degisikliklerini aninda yansitir)
Set-Location (Split-Path $PSScriptRoot -Parent)
if (!(Test-Path 'service-account.json')) {
    Write-Host '[HATA] service-account.json bulunamadi!' -ForegroundColor Red
    Write-Host 'Firebase Console > Proje Ayarlari > Hizmet Hesaplari > JSON indir' -ForegroundColor Yellow
    exit 1
}
docker-compose up --build