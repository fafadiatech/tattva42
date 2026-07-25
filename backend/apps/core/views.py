"""
ViewSets for core app: Person, Session, Utterance, Extraction, Thread.
"""
from django.shortcuts import get_object_or_404
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response

from .filters import ExtractionFilter, SessionFilter, UtteranceFilter
from .models import Extraction, Person, Session, Thread, Utterance
from .serializers import (
    ExtractionSerializer,
    PersonSerializer,
    SessionDetailSerializer,
    SessionListSerializer,
    ThreadSerializer,
    UtteranceSerializer,
)


class PersonViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer
    search_fields = ['name', 'role', 'org']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']


class SessionViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Session.objects.prefetch_related('participants').all()
    filterset_class = SessionFilter
    search_fields = ['title', 'summary', 'location']
    ordering_fields = ['started_at', 'created_at', 'duration_seconds', 'title']
    ordering = ['-started_at']

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return SessionDetailSerializer
        return SessionListSerializer

    @action(detail=True, methods=['get'], url_path='utterances')
    def utterances(self, request, pk=None):
        session = get_object_or_404(Session, pk=pk)
        qs = session.utterances.select_related('speaker').order_by('offset_ms')
        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = UtteranceSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = UtteranceSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['get'], url_path='extractions')
    def extractions(self, request, pk=None):
        session = get_object_or_404(Session, pk=pk)
        qs = session.extractions.select_related('owed_by', 'utterance').order_by('-created_at')
        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = ExtractionSerializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = ExtractionSerializer(qs, many=True, context={'request': request})
        return Response(serializer.data)

    @action(
        detail=True,
        methods=['post'],
        url_path='upload-audio',
        parser_classes=[MultiPartParser],
    )
    def upload_audio(self, request, pk=None):
        session = get_object_or_404(Session, pk=pk)
        audio_file = request.FILES.get('audio')
        if not audio_file:
            return Response(
                {'detail': 'No audio file provided.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        session.audio_file = audio_file
        session.save(update_fields=['audio_file', 'updated_at'])
        serializer = SessionListSerializer(session, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)


class UtteranceViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Utterance.objects.select_related('session', 'speaker').all()
    serializer_class = UtteranceSerializer
    filterset_class = UtteranceFilter
    search_fields = ['text']
    ordering_fields = ['offset_ms', 'created_at']
    ordering = ['offset_ms']


class ExtractionViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Extraction.objects.select_related('session', 'utterance', 'owed_by').all()
    serializer_class = ExtractionSerializer
    filterset_class = ExtractionFilter
    search_fields = ['text', 'due_hint']
    ordering_fields = ['created_at', 'kind', 'status']
    ordering = ['-created_at']

    @action(detail=True, methods=['patch'], url_path='accept')
    def accept(self, request, pk=None):
        extraction = get_object_or_404(Extraction, pk=pk)
        extraction.status = Extraction.Status.ACCEPTED
        extraction.save(update_fields=['status', 'updated_at'])
        serializer = self.get_serializer(extraction)
        return Response(serializer.data)

    @action(detail=True, methods=['patch'], url_path='dismiss')
    def dismiss(self, request, pk=None):
        extraction = get_object_or_404(Extraction, pk=pk)
        extraction.status = Extraction.Status.DISMISSED
        extraction.save(update_fields=['status', 'updated_at'])
        serializer = self.get_serializer(extraction)
        return Response(serializer.data)


class ThreadViewSet(
    mixins.CreateModelMixin,
    mixins.RetrieveModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    mixins.ListModelMixin,
    viewsets.GenericViewSet,
):
    queryset = Thread.objects.prefetch_related('sessions').all()
    serializer_class = ThreadSerializer
    search_fields = ['title']
    ordering_fields = ['title', 'created_at', 'updated_at']
    ordering = ['-updated_at']
