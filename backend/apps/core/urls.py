"""
URL routing for the core app.
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    ExtractionViewSet,
    PersonViewSet,
    SessionViewSet,
    ThreadViewSet,
    UtteranceViewSet,
)

router = DefaultRouter()
router.register(r'people', PersonViewSet, basename='person')
router.register(r'sessions', SessionViewSet, basename='session')
router.register(r'utterances', UtteranceViewSet, basename='utterance')
router.register(r'extractions', ExtractionViewSet, basename='extraction')
router.register(r'threads', ThreadViewSet, basename='thread')

urlpatterns = [
    path('', include(router.urls)),
]
