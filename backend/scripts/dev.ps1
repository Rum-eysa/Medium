Set-Location (Split-Path $PSScriptRoot -Parent)
.\.venv\Scripts\activate
uvicorn main:app --reload --port 8000 --log-level debug