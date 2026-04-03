# Lokal gelistirme (venv ile, Docker olmadan)
Set-Location (Split-Path $PSScriptRoot -Parent)
if (!(Test-Path '.\.venv\Scripts\activate')) {
    Write-Host '[!] venv bulunamadi. python -m venv .venv && pip install -r requirements.txt' -ForegroundColor Yellow
    exit 1
}
.\.venv\Scripts\activate
uvicorn main:app --reload --port 8000 --log-level debug