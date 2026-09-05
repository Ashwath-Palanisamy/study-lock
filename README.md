# StudyLock

StudyLock is a study companion with a Flutter mobile app, Android focus
lockdown, and a FastAPI backend for AI-assisted study preparation.

## Repository layout

| Project | Description | Documentation |
| --- | --- | --- |
| [`studylock/`](studylock/) | Flutter frontend and Android accessibility service | [`studylock/README.md`](studylock/README.md) |
| [`studylock_backend/`](studylock_backend/) | FastAPI backend for uploads, chat, and MCQ generation | [`studylock_backend/README.md`](studylock_backend/README.md) |

## Documentation map

### Product and architecture

- [Product Requirements Document](studylock/docs/PRD.md)
- [High-Level Design](studylock/docs/HLD.md)
- [Low-Level Design](studylock/docs/LLD.md)

### Frontend

- [Frontend README](studylock/docs/frontend/README.md)
- [Flutter tests](studylock/test/)
- [Frontend license](studylock/LICENSE)

### Backend

- [Backend README](studylock/docs/backend/README.md)
- [Backend tests](studylock_backend/tests/)
- [Backend license](studylock_backend/LICENSE)
- [Backend environment template](studylock_backend/.env.example)

## Quick start

### Frontend

```bash
cd studylock
flutter pub get
flutter run --dart-define=STUDYLOCK_API_KEY="your-app-key"
```

Build an Android release APK:

```bash
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/symbols \
  --dart-define=STUDYLOCK_API_KEY="your-app-key"
```

### Backend

```bash
cd studylock_backend
cp .env.example .env
# Set GOOGLE_API_KEY and STUDYLOCK_APP_API_KEY in .env
.venv/bin/uvicorn src.main:app --reload --port 8000
```

Run tests:

```bash
# Frontend
cd studylock && flutter test

# Backend
cd studylock_backend && .venv/bin/pytest
```

## License

Both projects are released under the [MIT License](studylock/LICENSE). The
backend includes the same license in
[`studylock_backend/LICENSE`](studylock_backend/LICENSE).
