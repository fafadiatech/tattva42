"""
Custom DRF permissions for the core app.
"""
from rest_framework.permissions import AllowAny


# Placeholder for future auth. Currently all endpoints are open.
class IsOwnerOrReadOnly(AllowAny):
    """Allow any access for now; extend when auth is added."""
    pass
