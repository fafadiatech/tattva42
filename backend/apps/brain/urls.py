"""
URL routing for the brain app.
"""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import AskView, PinnedMomentViewSet, SavedQueryViewSet

router = DefaultRouter()
router.register(r'saved-queries', SavedQueryViewSet, basename='savedquery')
router.register(r'pinned-moments', PinnedMomentViewSet, basename='pinnedmoment')

urlpatterns = [
    path('ask/', AskView.as_view(), name='ask'),
    path('', include(router.urls)),
]
