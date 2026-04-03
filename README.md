# projem

Solo gelistirici monorepo — FastAPI + Firestore + Flutter/GetX

## Mimari

\\\
projem/
├── backend/
│   ├── app/
│   │   ├── core/         Config, Firebase/Firestore init, Exceptions
│   │   ├── api/          Router, Middleware, Depends (Firestore inject)
│   │   ├── schemas/      Pydantic v2 — Flutter model mirror
│   │   └── services/     Firestore CRUD + AI/Video plug-in ABC
│   ├── scripts/          Gelistirici kısayolları
│   ├── Dockerfile
│   ├── docker-compose.yml        (gelistirme)
│   ├── docker-compose.prod.yml   (production override)
│   └── main.py
└── frontend/
    └── lib/
        ├── core/          ApiClient, Envelope, Constants
        └── features/auth/ UserModel, AuthController, LoginView
\\\

## Hizli Baslangic

### 1. Firebase service-account.json'u al
Firebase Console > Proje Ayarları > Hizmet Hesaplari > Yeni Anahtar Olustur > JSON

Dosyayi buraya koy: \ackend/service-account.json\

### 2. .env'i duzenle
\\\
backend/.env icindeki FIREBASE_PROJECT_ID'yi guncelle
\\\

### 3. Docker ile baslat (onerilir)
\\\powershell
cd backend
.\scripts\docker-dev.ps1
\\\

### 4. API dokumantasyonu
http://localhost:8000/docs

### 5. Flutter baslat
\\\powershell
cd frontend
flutter pub get && flutter run
\\\

## Docker Komutlari

| Komut | Aciklama |
|-------|---------|
| \.\scripts\docker-dev.ps1\ | Gelistirme ortami (hot-reload yok, kod mount edilir) |
| \.\scripts\docker-prod.ps1\ | Production build (4 worker, arka planda) |
| \.\scripts\docker-stop.ps1\ | Container'i durdur |
| \.\scripts\docker-logs.ps1\ | Canli log takibi |

## Firestore Koleksiyonlari

| Koleksiyon | Aciklama |
|-----------|---------|
| \users\ | Kullanici profilleri (dokuman ID = firebase_uid) |

## Ortam Degiskenleri (backend/.env)

| Degisken | Aciklama |
|---------|---------|
| \FIREBASE_PROJECT_ID\ | Firebase proje ID |
| \FIREBASE_CREDENTIALS_PATH\ | service-account.json yolu |
| \FIRESTORE_USERS_COLLECTION\ | Kullanici koleksiyon adi |
| \DEBUG\ | True = Swagger UI aktif |