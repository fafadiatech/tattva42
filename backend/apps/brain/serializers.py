"""
Serializers for brain app models.
"""
from rest_framework import serializers

from .models import PinnedMoment, SavedQuery


class SavedQuerySerializer(serializers.ModelSerializer):
    class Meta:
        model = SavedQuery
        fields = ['id', 'query_text', 'created_at']
        read_only_fields = ['id', 'created_at']


class PinnedMomentSerializer(serializers.ModelSerializer):
    # Include basic utterance context for display
    utterance_text = serializers.CharField(
        source='utterance.text', read_only=True
    )
    utterance_offset_ms = serializers.IntegerField(
        source='utterance.offset_ms', read_only=True
    )
    session_id = serializers.UUIDField(
        source='utterance.session_id', read_only=True
    )
    session_title = serializers.CharField(
        source='utterance.session.title', read_only=True
    )

    class Meta:
        model = PinnedMoment
        fields = [
            'id',
            'utterance',
            'utterance_text',
            'utterance_offset_ms',
            'session_id',
            'session_title',
            'note',
            'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class CitationSerializer(serializers.Serializer):
    """Read-only serializer for ask-endpoint citations."""
    session_id = serializers.UUIDField()
    utterance_id = serializers.UUIDField()
    session_title = serializers.CharField()
    snippet = serializers.CharField()
    offset_ms = serializers.IntegerField()


class AskResponseSerializer(serializers.Serializer):
    """Read-only serializer for ask-endpoint response."""
    answer = serializers.CharField()
    citations = CitationSerializer(many=True)
