"""
Admin registration for core app models.
"""
from django.contrib import admin

from .models import Extraction, Person, Session, Thread, Utterance


@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ['name', 'role', 'org', 'voiceprint_enrolled', 'created_at']
    list_filter = ['voiceprint_enrolled', 'org']
    search_fields = ['name', 'role', 'org']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['name']


@admin.register(Session)
class SessionAdmin(admin.ModelAdmin):
    list_display = [
        'title', 'mode', 'started_at', 'duration_seconds',
        'sync_state', 'is_private', 'is_seeded',
    ]
    list_filter = ['mode', 'sync_state', 'is_private', 'is_seeded']
    search_fields = ['title', 'summary', 'location']
    readonly_fields = ['id', 'created_at', 'updated_at']
    filter_horizontal = ['participants']
    ordering = ['-started_at']
    date_hierarchy = 'started_at'


@admin.register(Utterance)
class UtteranceAdmin(admin.ModelAdmin):
    list_display = ['session', 'speaker', 'offset_ms', 'confidence', 'created_at']
    list_filter = ['session', 'speaker']
    search_fields = ['text']
    readonly_fields = ['id', 'created_at']
    ordering = ['session', 'offset_ms']
    raw_id_fields = ['session', 'speaker']


@admin.register(Extraction)
class ExtractionAdmin(admin.ModelAdmin):
    list_display = ['kind', 'status', 'session', 'owed_by', 'due_hint', 'created_at']
    list_filter = ['kind', 'status']
    search_fields = ['text', 'due_hint']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-created_at']
    raw_id_fields = ['session', 'utterance', 'owed_by']


@admin.register(Thread)
class ThreadAdmin(admin.ModelAdmin):
    list_display = ['title', 'created_at', 'updated_at']
    search_fields = ['title']
    readonly_fields = ['id', 'created_at', 'updated_at']
    filter_horizontal = ['sessions']
    ordering = ['-updated_at']
