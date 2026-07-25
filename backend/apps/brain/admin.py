"""
Admin registration for brain app models.
"""
from django.contrib import admin

from .models import PinnedMoment, SavedQuery


@admin.register(SavedQuery)
class SavedQueryAdmin(admin.ModelAdmin):
    list_display = ['query_text', 'created_at']
    search_fields = ['query_text']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']


@admin.register(PinnedMoment)
class PinnedMomentAdmin(admin.ModelAdmin):
    list_display = ['utterance', 'note', 'created_at']
    search_fields = ['note', 'utterance__text']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']
    raw_id_fields = ['utterance']
