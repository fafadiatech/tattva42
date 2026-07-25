# Tattva42 Backend

Django + Django REST Framework backend for the Tattva42 "second brain" app — a wearable/phone audio capture service that records conversations, transcribes them, extracts commitments/decisions, and lets users search across recordings.

---

## Quick start with Docker

**Prerequisites:** Docker + Docker Compose installed.

```bash
cd backend/

# 1. Copy env file (defaults work out of the box for Docker)
cp .env.example .env

# 2. Start Postgres + Django dev server
docker compose up --build

# 3. In a second terminal, run migrations
docker compose exec web python manage.py migrate

# 4. Create a superuser (optional)
docker compose exec web python manage.py createsuperuser

# 5. Seed the database with mock data
docker compose exec web python manage.py seed_data
```

The API is now available at **http://localhost:8000/api/v1/**.
Django admin is at **http://localhost:8000/admin/**.

---

## Running locally (without Docker)

**Prerequisites:** Python 3.11+, optionally PostgreSQL (SQLite is the default).

```bash
cd backend/

# Create and activate a virtual environment
python3.11 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements-dev.txt

# Copy and edit env file
cp .env.example .env
# Set DJANGO_SETTINGS_MODULE=config.settings.development (already the default)

# Run migrations (uses SQLite by default)
python manage.py migrate

# Load seed data
python manage.py seed_data

# Start the development server
python manage.py runserver
```

---

## API overview

All endpoints are prefixed with `/api/v1/`.

### People

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/people/` | List all people |
| POST | `/people/` | Create a person |
| GET | `/people/{id}/` | Retrieve a person |
| PUT/PATCH | `/people/{id}/` | Update a person |
| DELETE | `/people/{id}/` | Delete a person |

### Sessions

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/sessions/` | List sessions (supports `?mode=meeting&sync_state=synced`) |
| POST | `/sessions/` | Create a session |
| GET | `/sessions/{id}/` | Retrieve session with nested utterances + extractions |
| PUT/PATCH | `/sessions/{id}/` | Update session |
| DELETE | `/sessions/{id}/` | Delete session |
| GET | `/sessions/{id}/utterances/` | List utterances for a session |
| GET | `/sessions/{id}/extractions/` | List extractions for a session |
| POST | `/sessions/{id}/upload-audio/` | Upload audio file (multipart) |

### Utterances

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/utterances/` | List utterances (supports `?session=<uuid>&speaker=<uuid>`) |
| POST | `/utterances/` | Create an utterance |
| GET | `/utterances/{id}/` | Retrieve an utterance |
| PUT/PATCH | `/utterances/{id}/` | Update an utterance |
| DELETE | `/utterances/{id}/` | Delete an utterance |

### Extractions

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/extractions/` | List extractions (supports `?kind=commitment&status=pending`) |
| POST | `/extractions/` | Create an extraction |
| GET | `/extractions/{id}/` | Retrieve an extraction |
| PUT/PATCH | `/extractions/{id}/` | Update an extraction |
| DELETE | `/extractions/{id}/` | Delete an extraction |
| PATCH | `/extractions/{id}/accept/` | Mark extraction as accepted |
| PATCH | `/extractions/{id}/dismiss/` | Mark extraction as dismissed |

### Threads

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/threads/` | List threads |
| POST | `/threads/` | Create a thread |
| GET | `/threads/{id}/` | Retrieve a thread with nested sessions |
| PUT/PATCH | `/threads/{id}/` | Update a thread |
| DELETE | `/threads/{id}/` | Delete a thread |

### Brain / Ask

| Method | URL | Description |
|--------|-----|-------------|
| POST | `/ask/` | Search utterances by keyword; returns answer + citations |
| GET | `/saved-queries/` | List saved queries |
| POST | `/saved-queries/` | Save a query |
| DELETE | `/saved-queries/{id}/` | Delete a saved query |
| GET | `/pinned-moments/` | List pinned moments |
| POST | `/pinned-moments/` | Pin a moment |
| DELETE | `/pinned-moments/{id}/` | Unpin a moment |

#### Ask endpoint example

```bash
curl -X POST http://localhost:8000/api/v1/ask/ \
  -H "Content-Type: application/json" \
  -d '{"query": "mobile redesign timeline"}'
```

Response:
```json
{
  "answer": "Found 3 relevant moment(s) matching \"mobile redesign timeline\" ...",
  "citations": [
    {
      "session_id": "...",
      "utterance_id": "...",
      "session_title": "Q4 Product Roadmap Planning",
      "snippet": "...",
      "offset_ms": 23500
    }
  ]
}
```

---

## Seed data

The `seed_data` management command loads 6 sessions matching the Flutter app's mock data:

1. Q4 Product Roadmap Planning (meeting, 54 min)
2. Sales Call with Prospect Inc (meeting, 30 min)
3. Morning Commute — Project Thoughts (dictation, 7 min)
4. Investor Update — Series B Prep (meeting, 45 min)
5. Design Review — Mobile App Redesign (meeting, 35 min)
6. Ambient Capture — Office Afternoon (ambient, 90 min)

```bash
# Load seed data
python manage.py seed_data

# Reset (delete seeded data) then reload
python manage.py seed_data --reset
```

---

## Project structure

```
backend/
  manage.py
  requirements.txt          # production dependencies
  requirements-dev.txt      # development dependencies (adds ipython, django-extensions)
  Dockerfile
  docker-compose.yml
  .env.example
  config/
    settings/
      base.py               # shared settings
      development.py        # SQLite + CORS open + BrowsableAPI
      production.py         # PostgreSQL + security headers
    urls.py
    wsgi.py
    asgi.py
  apps/
    core/
      models.py             # Person, Session, Utterance, Extraction, Thread
      serializers.py
      views.py
      urls.py
      admin.py
      filters.py
      management/commands/
        seed_data.py
    brain/
      models.py             # SavedQuery, PinnedMoment
      serializers.py
      views.py
      urls.py
      admin.py
```
