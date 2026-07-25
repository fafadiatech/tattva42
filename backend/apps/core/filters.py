"""
django-filter FilterSets for the core app.
"""
import django_filters

from .models import Extraction, Session, Utterance


class SessionFilter(django_filters.FilterSet):
    mode = django_filters.CharFilter(field_name='mode', lookup_expr='exact')
    sync_state = django_filters.CharFilter(field_name='sync_state', lookup_expr='exact')
    is_private = django_filters.BooleanFilter(field_name='is_private')
    is_seeded = django_filters.BooleanFilter(field_name='is_seeded')
    started_after = django_filters.DateTimeFilter(
        field_name='started_at', lookup_expr='gte'
    )
    started_before = django_filters.DateTimeFilter(
        field_name='started_at', lookup_expr='lte'
    )

    class Meta:
        model = Session
        fields = ['mode', 'sync_state', 'is_private', 'is_seeded']


class UtteranceFilter(django_filters.FilterSet):
    session = django_filters.UUIDFilter(field_name='session__id')
    speaker = django_filters.UUIDFilter(field_name='speaker__id')
    offset_min = django_filters.NumberFilter(field_name='offset_ms', lookup_expr='gte')
    offset_max = django_filters.NumberFilter(field_name='offset_ms', lookup_expr='lte')

    class Meta:
        model = Utterance
        fields = ['session', 'speaker']


class ExtractionFilter(django_filters.FilterSet):
    session = django_filters.UUIDFilter(field_name='session__id')
    kind = django_filters.CharFilter(field_name='kind', lookup_expr='exact')
    status = django_filters.CharFilter(field_name='status', lookup_expr='exact')
    owed_by = django_filters.UUIDFilter(field_name='owed_by__id')

    class Meta:
        model = Extraction
        fields = ['session', 'kind', 'status', 'owed_by']
