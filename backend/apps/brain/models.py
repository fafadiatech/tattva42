"""
Brain app models: SavedQuery, PinnedMoment.
"""
import uuid

from django.db import models


class SavedQuery(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    query_text = models.CharField(max_length=1000)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name_plural = 'saved queries'

    def __str__(self):
        return self.query_text[:80]


class PinnedMoment(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    utterance = models.ForeignKey(
        'core.Utterance', on_delete=models.CASCADE, related_name='pinned_moments'
    )
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        note_preview = f' — {self.note[:40]}' if self.note else ''
        return f'Pinned: {self.utterance}{note_preview}'
