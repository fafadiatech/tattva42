# Tattva42

A second brain prototype for capturing, transcribing, and searching conversations, meetings, and ideas.

## Repository layout

```
tattva42/
  app/        Flutter mobile app (iOS + Android)
  backend/    Django REST Framework API
```

## App (`app/`)

Flutter application targeting iOS and Android. Records audio from the phone microphone, transcribes on-device, extracts commitments and decisions, and lets you search across everything.

**Stack:** Flutter / Dart 3, Riverpod, go_router, `record`, `just_audio`, `speech_to_text`

```bash
cd app
flutter pub get
flutter run          # requires a physical device for microphone
```

See `app/README.md` for full setup, permissions, and canned Ask queries.

## Backend (`backend/`)

Django + Django REST Framework API with PostgreSQL. Mirrors the app's data model — sessions, utterances, extractions, people, threads — and exposes a keyword-search `/ask/` endpoint.

**Stack:** Python 3.11, Django 4.2, DRF, PostgreSQL, Docker

```bash
cd backend
cp .env.example .env
docker compose up --build
docker compose exec web python manage.py migrate
docker compose exec web python manage.py seed_data
```

API available at `http://localhost:8000/api/v1/`. Admin at `http://localhost:8000/admin/`.

See `backend/README.md` for full API reference and local setup without Docker.
