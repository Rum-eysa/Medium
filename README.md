# projem

Solo gelistirici monorepo — FastAPI backend + Flutter frontend.

## Yapı

\\\
projem/
├── backend/          FastAPI (Python)
│   ├── app/
│   │   ├── core/     Config, DB, Firebase, Exceptions
│   │   ├── api/      Router, Middleware, Depends
│   │   ├── schemas/  Pydantic v2 (Flutter model mirror)
│   │   ├── models/   SQLAlchemy ORM
│   │   └── services/ Is mantigi + AI/Video plug-in ABC
│   ├── tests/
│   ├── scripts/      Gelistirici yardimci scriptleri
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── main.py
└── frontend/         Flutter (Dart)
    └── lib/
        ├── core/     ApiClient, Envelope, Constants, Error
        └── features/
            └── auth/ UserModel, AuthController, LoginView
\\\

## Hizli Baslangic

### Backend (gelistirme)
\\\powershell
cd backend
.\.venv\Scripts\activate
uvicorn main:app --reload --port 8000
# veya: .\scripts\dev.ps1
\\\

### Backend (Docker — production benzeri)
\\\powershell
cd backend
docker-compose up --build
\\\

### Frontend
\\\powershell
cd frontend
flutter pub get
flutter run
\\\

## Ortam Degiskenleri

\ackend\.env\ dosyasini duzenle:
| Degisken | Aciklama |
|---|---|
| \DATABASE_URL\ | PostgreSQL async URL |
| \FIREBASE_CREDENTIALS_PATH\ | service-account.json yolu |
| \FIREBASE_PROJECT_ID\ | Firebase proje ID |

## API

Gelistirme modunda Swagger UI: http://localhost:8000/docs