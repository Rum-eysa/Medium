FROM python:3.12-slim

WORKDIR /app

# Sistem bagımlılıkları (sadece gcc gerekli artık)
RUN apt-get update && apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*

# Bagımlılıkları once yukle (layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Uygulama kodunu kopyala
COPY . .

# service-account.json ASLA image'a gomme!
# docker-compose volume ile mount edilir
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]