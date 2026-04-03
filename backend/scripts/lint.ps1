Set-Location (Split-Path $PSScriptRoot -Parent)
.\.venv\Scripts\activate
ruff check . --fix
ruff format .