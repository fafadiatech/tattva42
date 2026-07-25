"""
Core data models: Person, Session, Utterance, Extraction, Thread.
"""
import uuid

from django.db import models


class Person(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    role = models.CharField(max_length=255, blank=True)
    org = models.CharField(max_length=255, blank=True)
    avatar_color = models.CharField(max_length=7)  # hex color e.g. "#4CAF50"
    voiceprint_enrolled = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']
        verbose_name_plural = 'people'

    def __str__(self):
        parts = [self.name]
        if self.role:
            parts.append(self.role)
        if self.org:
            parts.append(self.org)
        return ' — '.join(parts)


class Session(models.Model):
    class CaptureMode(models.TextChoices):
        AMBIENT = 'ambient', 'Ambient'
        MEETING = 'meeting', 'Meeting'
        DICTATION = 'dictation', 'Dictation'

    class SyncState(models.TextChoices):
        SYNCED = 'synced', 'Synced'
        PENDING = 'pending', 'Pending'
        LOCAL = 'local', 'Local'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=500)
    summary = models.TextField(blank=True)
    started_at = models.DateTimeField()
    duration_seconds = models.PositiveIntegerField(default=0)
    mode = models.CharField(max_length=20, choices=CaptureMode.choices)
    location = models.CharField(max_length=500, blank=True)
    participants = models.ManyToManyField(
        Person, blank=True, related_name='sessions'
    )
    sync_state = models.CharField(
        max_length=20, choices=SyncState.choices, default=SyncState.LOCAL
    )
    is_private = models.BooleanField(default=False)
    audio_file = models.FileField(upload_to='audio/', blank=True, null=True)
    is_seeded = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-started_at']

    def __str__(self):
        return f'{self.title} ({self.started_at.date()})'

    @property
    def duration_display(self):
        minutes, seconds = divmod(self.duration_seconds, 60)
        hours, minutes = divmod(minutes, 60)
        if hours:
            return f'{hours}h {minutes}m'
        return f'{minutes}m {seconds}s'


class Utterance(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(
        Session, on_delete=models.CASCADE, related_name='utterances'
    )
    speaker = models.ForeignKey(
        Person,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='utterances',
    )
    text = models.TextField()
    offset_ms = models.PositiveIntegerField()  # milliseconds from session start
    end_ms = models.PositiveIntegerField(null=True, blank=True)
    confidence = models.FloatField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['offset_ms']

    def __str__(self):
        speaker_name = self.speaker.name if self.speaker else 'Unknown'
        preview = self.text[:60]
        if len(self.text) > 60:
            preview += '...'
        return f'[{speaker_name} @ {self.offset_ms}ms] {preview}'


class Extraction(models.Model):
    class Kind(models.TextChoices):
        COMMITMENT = 'commitment', 'Commitment'
        DECISION = 'decision', 'Decision'
        QUESTION = 'question', 'Question'
        FIGURE = 'figure', 'Figure'

    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        ACCEPTED = 'accepted', 'Accepted'
        DISMISSED = 'dismissed', 'Dismissed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(
        Session, on_delete=models.CASCADE, related_name='extractions'
    )
    utterance = models.ForeignKey(
        Utterance, on_delete=models.CASCADE, related_name='extractions'
    )
    text = models.TextField()
    kind = models.CharField(max_length=20, choices=Kind.choices)
    owed_by = models.ForeignKey(
        Person,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='owed_extractions',
    )
    due_hint = models.CharField(max_length=255, blank=True)
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.PENDING
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'[{self.kind}] {self.text[:80]}'


class Thread(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.CharField(max_length=500)
    sessions = models.ManyToManyField(Session, blank=True, related_name='threads')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return self.title
