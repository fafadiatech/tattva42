"""
Development settings for Tattva42 backend.
"""
from .base import *  # noqa: F401, F403

DEBUG = True

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',  # noqa: F405
    }
}

MEDIA_ROOT = str(BASE_DIR / 'media')  # noqa: F405

# CORS: allow all origins in development
CORS_ALLOW_ALL_ORIGINS = True

# Add BrowsableAPIRenderer in dev for easier exploration
REST_FRAMEWORK = {  # noqa: F405
    **REST_FRAMEWORK,  # noqa: F405
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
}
