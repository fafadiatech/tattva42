"""
Views for brain app: Ask (AIView), SavedQuery, PinnedMoment.
"""
from django.db.models import Q
from rest_framework import mixins, status, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.core.models import Utterance

from .models import PinnedMoment, SavedQuery
from .serializers import (
    AskResponseSerializer,
    PinnedMomentSerializer,
    SavedQuerySerializer,
)


class AskView(APIView):
    """
    POST /api/v1/ask/

    Body: {"query": "some question about past conversations"}

    Keyword-searches Utterance.text for each word in the query.
    Returns the top 5 utterances ranked by how many query words they contain,
    along with a plain-text answer assembled from the results.
    """

    def post(self, request):
        query = request.data.get('query', '').strip()
        if not query:
            return Response(
                {'detail': 'query field is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        words = [w for w in query.lower().split() if len(w) > 2]
        if not words:
            return Response(
                {'answer': 'No meaningful search terms found.', 'citations': []},
                status=status.HTTP_200_OK,
            )

        # Build a queryset that matches any word
        combined_q = Q()
        for word in words:
            combined_q |= Q(text__icontains=word)

        utterances = (
            Utterance.objects.filter(combined_q)
            .select_related('session', 'speaker')
            .distinct()
        )

        # Score each utterance by number of matched words
        def score(utterance):
            lower_text = utterance.text.lower()
            return sum(1 for w in words if w in lower_text)

        scored = sorted(utterances, key=score, reverse=True)[:5]

        citations = []
        for u in scored:
            citations.append(
                {
                    'session_id': u.session_id,
                    'utterance_id': u.id,
                    'session_title': u.session.title,
                    'snippet': u.text[:200],
                    'offset_ms': u.offset_ms,
                }
            )

        if citations:
            titles = ', '.join(
                {c['session_title'] for c in citations}
            )
            answer = (
                f'Found {len(citations)} relevant moment(s) matching "{query}" '
                f'across session(s): {titles}.'
            )
        else:
            answer = f'No results found for "{query}".'

        serializer = AskResponseSerializer({'answer': answer, 'citations': citations})
        return Response(serializer.data, status=status.HTTP_200_OK)


class SavedQueryViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,
):
    queryset = SavedQuery.objects.all()
    serializer_class = SavedQuerySerializer
    ordering = ['-created_at']


class PinnedMomentViewSet(
    mixins.CreateModelMixin,
    mixins.ListModelMixin,
    mixins.DestroyModelMixin,
    viewsets.GenericViewSet,
):
    queryset = PinnedMoment.objects.select_related(
        'utterance', 'utterance__session'
    ).all()
    serializer_class = PinnedMomentSerializer
    ordering = ['-created_at']
