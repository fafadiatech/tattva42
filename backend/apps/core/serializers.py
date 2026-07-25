"""
Serializers for core app models.
"""
from rest_framework import serializers

from .models import Extraction, Person, Session, Thread, Utterance


class PersonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Person
        fields = [
            'id',
            'name',
            'role',
            'org',
            'avatar_color',
            'voiceprint_enrolled',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class UtteranceSerializer(serializers.ModelSerializer):
    speaker_name = serializers.CharField(
        source='speaker.name', read_only=True, allow_null=True
    )

    class Meta:
        model = Utterance
        fields = [
            'id',
            'session',
            'speaker',
            'speaker_name',
            'text',
            'offset_ms',
            'end_ms',
            'confidence',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class ExtractionSerializer(serializers.ModelSerializer):
    owed_by_name = serializers.CharField(
        source='owed_by.name', read_only=True, allow_null=True
    )

    class Meta:
        model = Extraction
        fields = [
            'id',
            'session',
            'utterance',
            'text',
            'kind',
            'owed_by',
            'owed_by_name',
            'due_hint',
            'status',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class SessionListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for session list views."""
    participants = PersonSerializer(many=True, read_only=True)
    participant_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Person.objects.all(),
        write_only=True,
        source='participants',
        required=False,
    )
    utterance_count = serializers.SerializerMethodField()
    extraction_count = serializers.SerializerMethodField()

    class Meta:
        model = Session
        fields = [
            'id',
            'title',
            'summary',
            'started_at',
            'duration_seconds',
            'mode',
            'location',
            'participants',
            'participant_ids',
            'sync_state',
            'is_private',
            'audio_file',
            'is_seeded',
            'utterance_count',
            'extraction_count',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_utterance_count(self, obj):
        return obj.utterances.count()

    def get_extraction_count(self, obj):
        return obj.extractions.count()


class SessionDetailSerializer(SessionListSerializer):
    """Full serializer including nested utterances and extractions."""
    utterances = UtteranceSerializer(many=True, read_only=True)
    extractions = ExtractionSerializer(many=True, read_only=True)

    class Meta(SessionListSerializer.Meta):
        fields = SessionListSerializer.Meta.fields + ['utterances', 'extractions']


class ThreadSerializer(serializers.ModelSerializer):
    sessions = SessionListSerializer(many=True, read_only=True)
    session_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=Session.objects.all(),
        write_only=True,
        source='sessions',
        required=False,
    )

    class Meta:
        model = Thread
        fields = [
            'id',
            'title',
            'sessions',
            'session_ids',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
