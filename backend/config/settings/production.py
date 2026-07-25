"""
Production settings for Tattva42 backend.
"""
import dj_database_url

from .base import *  # noqa: F401, F403

DEBUG = False

# Database from DATABASE_URL env var
DATABASES = {
    'default': dj_database_url.config(
        env='DATABASE_URL',
        conn_max_age=600,
        conn_health_checks=True,
    )
}

# CORS: restrict to explicit allowed origins in production
CORS_ALLOWED_ORIGINS = [
    o.strip()
    for o in os.environ.get('CORS_ALLOWED_ORIGINS', '').split(',')  # noqa: F405
    if o.strip()
]

# Security
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

STATIC_ROOT = BASE_DIR / 'staticfiles'  # noqa: F405
MEDIA_ROOT = os.environ.get('MEDIA_ROOT', str(BASE_DIR / 'media'))  # noqa: F405
