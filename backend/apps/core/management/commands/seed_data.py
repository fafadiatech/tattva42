"""
Management command: seed_data

Populates the database with the same 6 sessions (+ people, utterances,
extractions) that appear in the Flutter app's mock data.

Usage:
    python manage.py seed_data            # load seed data
    python manage.py seed_data --reset    # delete existing seeded data first
"""
import uuid
from datetime import datetime, timezone

from django.core.management.base import BaseCommand
from django.utils import timezone as dj_timezone

from apps.core.models import Extraction, Person, Session, Thread, Utterance


# ---------------------------------------------------------------------------
# Seed data – mirrors Flutter MockDataService
# ---------------------------------------------------------------------------

PEOPLE = [
    {
        'id': 'a1b2c3d4-0001-0000-0000-000000000001',
        'name': 'Alice Chen',
        'role': 'Product Manager',
        'org': 'Acme Corp',
        'avatar_color': '#4CAF50',
        'voiceprint_enrolled': True,
    },
    {
        'id': 'a1b2c3d4-0002-0000-0000-000000000002',
        'name': 'Bob Kumar',
        'role': 'Engineering Lead',
        'org': 'Acme Corp',
        'avatar_color': '#2196F3',
        'voiceprint_enrolled': True,
    },
    {
        'id': 'a1b2c3d4-0003-0000-0000-000000000003',
        'name': 'Carol Singh',
        'role': 'Designer',
        'org': 'Acme Corp',
        'avatar_color': '#E91E63',
        'voiceprint_enrolled': False,
    },
    {
        'id': 'a1b2c3d4-0004-0000-0000-000000000004',
        'name': 'David Park',
        'role': 'CTO',
        'org': 'Acme Corp',
        'avatar_color': '#FF9800',
        'voiceprint_enrolled': True,
    },
    {
        'id': 'a1b2c3d4-0005-0000-0000-000000000005',
        'name': 'Eva Martinez',
        'role': 'Sales Director',
        'org': 'Prospect Inc',
        'avatar_color': '#9C27B0',
        'voiceprint_enrolled': False,
    },
    {
        'id': 'a1b2c3d4-0006-0000-0000-000000000006',
        'name': 'Frank Liu',
        'role': 'Investor',
        'org': 'Venture Capital Co',
        'avatar_color': '#00BCD4',
        'voiceprint_enrolled': False,
    },
]

# Each session dict contains nested utterances + extractions for convenience.
SESSIONS = [
    {
        'id': '50000001-0000-0000-0000-000000000001',
        'title': 'Q4 Product Roadmap Planning',
        'summary': (
            'Team aligned on Q4 priorities: mobile-first redesign, API v2, '
            'and performance improvements. Alice to own mobile spec by Friday. '
            'Bob flagged infra concerns needing David approval.'
        ),
        'started_at': '2025-11-15T10:00:00Z',
        'duration_seconds': 3240,
        'mode': 'meeting',
        'location': 'Conference Room A',
        'participant_names': ['Alice Chen', 'Bob Kumar', 'Carol Singh', 'David Park'],
        'sync_state': 'synced',
        'is_private': False,
        'utterances': [
            {
                'id': '60000001-0000-0000-0000-000000000001',
                'speaker_name': 'Alice Chen',
                'text': "Alright everyone, let's get started. Today we need to finalize the Q4 roadmap. I've prepared a draft that I'd like to walk through.",
                'offset_ms': 0,
                'end_ms': 8500,
                'confidence': 0.97,
            },
            {
                'id': '60000001-0000-0000-0000-000000000002',
                'speaker_name': 'Bob Kumar',
                'text': "Sounds good. Before we dive in, I want to flag that the infrastructure team has some concerns about the proposed timeline for the API migration.",
                'offset_ms': 9000,
                'end_ms': 17000,
                'confidence': 0.95,
            },
            {
                'id': '60000001-0000-0000-0000-000000000003',
                'speaker_name': 'David Park',
                'text': "Bob, let's make sure we address that today. We can't afford another delay like last quarter.",
                'offset_ms': 17500,
                'end_ms': 23000,
                'confidence': 0.98,
            },
            {
                'id': '60000001-0000-0000-0000-000000000004',
                'speaker_name': 'Alice Chen',
                'text': "Agreed. So the three main initiatives I'm proposing are: mobile-first redesign, API v2, and the performance improvements Carol's team identified.",
                'offset_ms': 23500,
                'end_ms': 33000,
                'confidence': 0.96,
            },
            {
                'id': '60000001-0000-0000-0000-000000000005',
                'speaker_name': 'Carol Singh',
                'text': "The performance work is critical. We're seeing 40% of users drop off during load times over 3 seconds.",
                'offset_ms': 33500,
                'end_ms': 41000,
                'confidence': 0.94,
            },
            {
                'id': '60000001-0000-0000-0000-000000000006',
                'speaker_name': 'Bob Kumar',
                'text': "I can have the infrastructure assessment done by end of week. But I need sign-off from David on the additional cloud spend — we're looking at roughly $50k per month.",
                'offset_ms': 41500,
                'end_ms': 53000,
                'confidence': 0.97,
            },
            {
                'id': '60000001-0000-0000-0000-000000000007',
                'speaker_name': 'David Park',
                'text': "Approved in principle, pending the detailed breakdown. Send me the numbers and I'll sign off by Thursday.",
                'offset_ms': 53500,
                'end_ms': 61000,
                'confidence': 0.99,
            },
            {
                'id': '60000001-0000-0000-0000-000000000008',
                'speaker_name': 'Alice Chen',
                'text': "Great. I'll own the mobile spec and have a draft ready by Friday for everyone to review.",
                'offset_ms': 61500,
                'end_ms': 68000,
                'confidence': 0.98,
            },
        ],
        'extractions': [
            {
                'id': '70000001-0001-0000-0000-000000000001',
                'utterance_idx': 7,  # 0-based index into utterances list
                'text': 'Alice to have mobile spec draft ready by Friday for team review',
                'kind': 'commitment',
                'owed_by_name': 'Alice Chen',
                'due_hint': 'Friday',
                'status': 'pending',
            },
            {
                'id': '70000001-0002-0000-0000-000000000002',
                'utterance_idx': 5,
                'text': 'Bob to complete infrastructure assessment by end of week',
                'kind': 'commitment',
                'owed_by_name': 'Bob Kumar',
                'due_hint': 'End of week',
                'status': 'accepted',
            },
            {
                'id': '70000001-0003-0000-0000-000000000003',
                'utterance_idx': 6,
                'text': 'David to sign off on $50k/month cloud spend by Thursday',
                'kind': 'commitment',
                'owed_by_name': 'David Park',
                'due_hint': 'Thursday',
                'status': 'pending',
            },
            {
                'id': '70000001-0004-0000-0000-000000000004',
                'utterance_idx': 4,
                'text': '40% of users drop off during load times over 3 seconds',
                'kind': 'figure',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
            {
                'id': '70000001-0005-0000-0000-000000000005',
                'utterance_idx': 3,
                'text': 'Q4 priorities decided: mobile-first redesign, API v2, performance improvements',
                'kind': 'decision',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
        ],
    },
    {
        'id': '50000002-0000-0000-0000-000000000002',
        'title': 'Sales Call with Prospect Inc',
        'summary': (
            'Positive call with Eva Martinez. Prospect interested in enterprise '
            'plan at $2,400/year. Demo scheduled for next Tuesday. '
            'Custom SSO integration may be a dealbreaker if not included.'
        ),
        'started_at': '2025-11-14T14:30:00Z',
        'duration_seconds': 1800,
        'mode': 'meeting',
        'location': 'Video Call',
        'participant_names': ['Alice Chen', 'Eva Martinez'],
        'sync_state': 'synced',
        'is_private': False,
        'utterances': [
            {
                'id': '60000002-0000-0000-0000-000000000001',
                'speaker_name': 'Alice Chen',
                'text': "Hi Eva, thanks for making time today. I wanted to give you a proper walkthrough of our enterprise features.",
                'offset_ms': 0,
                'end_ms': 7000,
                'confidence': 0.97,
            },
            {
                'id': '60000002-0000-0000-0000-000000000002',
                'speaker_name': 'Eva Martinez',
                'text': "Of course! We've been evaluating several solutions and yours came highly recommended. What's the pricing structure look like for a team of 200?",
                'offset_ms': 7500,
                'end_ms': 18000,
                'confidence': 0.93,
            },
            {
                'id': '60000002-0000-0000-0000-000000000003',
                'speaker_name': 'Alice Chen',
                'text': "For 200 seats on our enterprise plan, you'd be looking at $12 per user per month, so $2,400 per month or $24,000 annually with our yearly discount.",
                'offset_ms': 18500,
                'end_ms': 30000,
                'confidence': 0.98,
            },
            {
                'id': '60000002-0000-0000-0000-000000000004',
                'speaker_name': 'Eva Martinez',
                'text': "That's within our budget. One major concern is SSO integration — we use Okta and that's non-negotiable for our security team.",
                'offset_ms': 30500,
                'end_ms': 40000,
                'confidence': 0.95,
            },
            {
                'id': '60000002-0000-0000-0000-000000000005',
                'speaker_name': 'Alice Chen',
                'text': "We do support Okta via SAML 2.0. I'll send you the integration documentation after this call. Can we schedule a technical demo for next Tuesday?",
                'offset_ms': 40500,
                'end_ms': 52000,
                'confidence': 0.96,
            },
            {
                'id': '60000002-0000-0000-0000-000000000006',
                'speaker_name': 'Eva Martinez',
                'text': "Tuesday works. Let's say 2 PM PST. Include our IT security lead, James, in that call.",
                'offset_ms': 52500,
                'end_ms': 60000,
                'confidence': 0.97,
            },
        ],
        'extractions': [
            {
                'id': '70000002-0001-0000-0000-000000000001',
                'utterance_idx': 4,
                'text': 'Alice to send Okta/SAML 2.0 integration documentation to Eva',
                'kind': 'commitment',
                'owed_by_name': 'Alice Chen',
                'due_hint': 'After call',
                'status': 'accepted',
            },
            {
                'id': '70000002-0002-0000-0000-000000000002',
                'utterance_idx': 5,
                'text': 'Technical demo scheduled for next Tuesday at 2 PM PST with IT security lead James',
                'kind': 'decision',
                'owed_by_name': None,
                'due_hint': 'Next Tuesday 2 PM PST',
                'status': 'accepted',
            },
            {
                'id': '70000002-0003-0000-0000-000000000003',
                'utterance_idx': 2,
                'text': 'Enterprise pricing: $12/user/month, $24,000/year for 200 seats',
                'kind': 'figure',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
        ],
    },
    {
        'id': '50000003-0000-0000-0000-000000000003',
        'title': 'Morning Commute — Project Thoughts',
        'summary': (
            'Voice memo captured during commute. Key insight: current onboarding '
            'flow has too many steps. Idea to add progress indicator and reduce '
            'to 3 steps. Need to validate with user research.'
        ),
        'started_at': '2025-11-14T08:15:00Z',
        'duration_seconds': 420,
        'mode': 'dictation',
        'location': 'Transit',
        'participant_names': ['Alice Chen'],
        'sync_state': 'synced',
        'is_private': True,
        'utterances': [
            {
                'id': '60000003-0000-0000-0000-000000000001',
                'speaker_name': 'Alice Chen',
                'text': "Thinking about the onboarding flow on the train. The current 7-step process is way too long. Users are dropping off at step 4.",
                'offset_ms': 0,
                'end_ms': 10000,
                'confidence': 0.91,
            },
            {
                'id': '60000003-0000-0000-0000-000000000002',
                'speaker_name': 'Alice Chen',
                'text': "Idea: consolidate to 3 steps. Step 1 is account basics, step 2 is team setup, step 3 is first project. Add a visual progress indicator throughout.",
                'offset_ms': 10500,
                'end_ms': 22000,
                'confidence': 0.93,
            },
            {
                'id': '60000003-0000-0000-0000-000000000003',
                'speaker_name': 'Alice Chen',
                'text': "Need to validate this with user research before implementing. Schedule a session with the UX research team this week.",
                'offset_ms': 22500,
                'end_ms': 31000,
                'confidence': 0.92,
            },
        ],
        'extractions': [
            {
                'id': '70000003-0001-0000-0000-000000000001',
                'utterance_idx': 2,
                'text': 'Schedule UX research session this week to validate 3-step onboarding concept',
                'kind': 'commitment',
                'owed_by_name': 'Alice Chen',
                'due_hint': 'This week',
                'status': 'pending',
            },
            {
                'id': '70000003-0002-0000-0000-000000000002',
                'utterance_idx': 0,
                'text': 'Users are dropping off at step 4 of the 7-step onboarding',
                'kind': 'figure',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
        ],
    },
    {
        'id': '50000004-0000-0000-0000-000000000004',
        'title': 'Investor Update — Series B Prep',
        'summary': (
            'Prep call with Frank Liu for Series B. ARR at $2.1M, '
            'targeting $4M by year end. Frank advised on pitch deck structure '
            'and committed to intro to 3 partner funds.'
        ),
        'started_at': '2025-11-13T16:00:00Z',
        'duration_seconds': 2700,
        'mode': 'meeting',
        'location': 'Video Call',
        'participant_names': ['David Park', 'Frank Liu'],
        'sync_state': 'synced',
        'is_private': True,
        'utterances': [
            {
                'id': '60000004-0000-0000-0000-000000000001',
                'speaker_name': 'David Park',
                'text': "Frank, appreciate you making time. We're targeting to kick off Series B in Q1 and wanted your guidance on positioning.",
                'offset_ms': 0,
                'end_ms': 10000,
                'confidence': 0.98,
            },
            {
                'id': '60000004-0000-0000-0000-000000000002',
                'speaker_name': 'Frank Liu',
                'text': "Happy to help. Where are you on ARR right now?",
                'offset_ms': 10500,
                'end_ms': 15000,
                'confidence': 0.99,
            },
            {
                'id': '60000004-0000-0000-0000-000000000003',
                'speaker_name': 'David Park',
                'text': "We're at $2.1M ARR, growing 15% month over month. We're targeting $4M by end of year based on the pipeline.",
                'offset_ms': 15500,
                'end_ms': 25000,
                'confidence': 0.97,
            },
            {
                'id': '60000004-0000-0000-0000-000000000004',
                'speaker_name': 'Frank Liu',
                'text': "Good growth. For Series B, you'll want to lead with net revenue retention and expansion revenue. Those are the metrics top-tier funds focus on right now.",
                'offset_ms': 25500,
                'end_ms': 37000,
                'confidence': 0.96,
            },
            {
                'id': '60000004-0000-0000-0000-000000000005',
                'speaker_name': 'Frank Liu',
                'text': "I can make introductions to three partner funds I think would be a good fit. Give me two weeks to set up warm intros.",
                'offset_ms': 37500,
                'end_ms': 47000,
                'confidence': 0.97,
            },
            {
                'id': '60000004-0000-0000-0000-000000000006',
                'speaker_name': 'David Park',
                'text': "That would be incredible. I'll have the updated pitch deck to you by Monday so you have context before the intros.",
                'offset_ms': 47500,
                'end_ms': 56000,
                'confidence': 0.98,
            },
        ],
        'extractions': [
            {
                'id': '70000004-0001-0000-0000-000000000001',
                'utterance_idx': 5,
                'text': 'David to send updated pitch deck to Frank by Monday',
                'kind': 'commitment',
                'owed_by_name': 'David Park',
                'due_hint': 'Monday',
                'status': 'accepted',
            },
            {
                'id': '70000004-0002-0000-0000-000000000002',
                'utterance_idx': 4,
                'text': 'Frank to make introductions to 3 partner funds within 2 weeks',
                'kind': 'commitment',
                'owed_by_name': 'Frank Liu',
                'due_hint': 'Within 2 weeks',
                'status': 'accepted',
            },
            {
                'id': '70000004-0003-0000-0000-000000000003',
                'utterance_idx': 2,
                'text': 'Current ARR: $2.1M, growing 15% MoM, targeting $4M by year end',
                'kind': 'figure',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
        ],
    },
    {
        'id': '50000005-0000-0000-0000-000000000005',
        'title': 'Design Review — Mobile App Redesign',
        'summary': (
            'Carol walked through new mobile design system. Navigation reduced '
            'from 5 tabs to 3. New component library approved. '
            'A/B test planned for December launch. Accessibility audit required.'
        ),
        'started_at': '2025-11-12T11:00:00Z',
        'duration_seconds': 2100,
        'mode': 'meeting',
        'location': 'Design Studio',
        'participant_names': ['Alice Chen', 'Carol Singh', 'Bob Kumar'],
        'sync_state': 'synced',
        'is_private': False,
        'utterances': [
            {
                'id': '60000005-0000-0000-0000-000000000001',
                'speaker_name': 'Carol Singh',
                'text': "I've been working on a complete design system refresh. The key insight from our user research is that the current 5-tab navigation is causing confusion.",
                'offset_ms': 0,
                'end_ms': 11000,
                'confidence': 0.95,
            },
            {
                'id': '60000005-0000-0000-0000-000000000002',
                'speaker_name': 'Alice Chen',
                'text': "What are you proposing instead?",
                'offset_ms': 11500,
                'end_ms': 14000,
                'confidence': 0.99,
            },
            {
                'id': '60000005-0000-0000-0000-000000000003',
                'speaker_name': 'Carol Singh',
                'text': "Three main areas: Capture, Review, and Brain. Everything else goes into a contextual slide-up panel. It massively reduces cognitive load.",
                'offset_ms': 14500,
                'end_ms': 24000,
                'confidence': 0.96,
            },
            {
                'id': '60000005-0000-0000-0000-000000000004',
                'speaker_name': 'Bob Kumar',
                'text': "I like it from a technical standpoint — fewer screens means less state management. Does this new component library have accessibility specs?",
                'offset_ms': 24500,
                'end_ms': 34000,
                'confidence': 0.94,
            },
            {
                'id': '60000005-0000-0000-0000-000000000005',
                'speaker_name': 'Carol Singh',
                'text': "Not yet — that's on my list. I'll run an accessibility audit before we hand off to engineering. WCAG 2.1 AA compliance is the target.",
                'offset_ms': 34500,
                'end_ms': 45000,
                'confidence': 0.93,
            },
            {
                'id': '60000005-0000-0000-0000-000000000006',
                'speaker_name': 'Alice Chen',
                'text': "Let's approve the design direction and plan an A/B test for the December release. We'll run it for 4 weeks and measure task completion rate.",
                'offset_ms': 45500,
                'end_ms': 57000,
                'confidence': 0.97,
            },
        ],
        'extractions': [
            {
                'id': '70000005-0001-0000-0000-000000000001',
                'utterance_idx': 4,
                'text': 'Carol to run WCAG 2.1 AA accessibility audit before engineering handoff',
                'kind': 'commitment',
                'owed_by_name': 'Carol Singh',
                'due_hint': 'Before engineering handoff',
                'status': 'pending',
            },
            {
                'id': '70000005-0002-0000-0000-000000000002',
                'utterance_idx': 5,
                'text': 'Approved: new 3-tab navigation design direction for mobile app',
                'kind': 'decision',
                'owed_by_name': None,
                'due_hint': '',
                'status': 'accepted',
            },
            {
                'id': '70000005-0003-0000-0000-000000000003',
                'utterance_idx': 5,
                'text': 'A/B test planned for December release, run 4 weeks, measure task completion rate',
                'kind': 'decision',
                'owed_by_name': None,
                'due_hint': 'December',
                'status': 'accepted',
            },
        ],
    },
    {
        'id': '50000006-0000-0000-0000-000000000006',
        'title': 'Ambient Capture — Office Afternoon',
        'summary': (
            'Ambient session from office. Captured several ad-hoc conversations '
            'including a quick sync on deployment schedule and a discussion '
            'about the upcoming company all-hands.'
        ),
        'started_at': '2025-11-11T13:00:00Z',
        'duration_seconds': 5400,
        'mode': 'ambient',
        'location': 'Office — Open Plan',
        'participant_names': ['Bob Kumar', 'Carol Singh'],
        'sync_state': 'pending',
        'is_private': False,
        'utterances': [
            {
                'id': '60000006-0000-0000-0000-000000000001',
                'speaker_name': 'Bob Kumar',
                'text': "Hey Carol, quick question — are we still on track for the Friday deployment?",
                'offset_ms': 12400,
                'end_ms': 17000,
                'confidence': 0.89,
            },
            {
                'id': '60000006-0000-0000-0000-000000000002',
                'speaker_name': 'Carol Singh',
                'text': "Should be. I just need to finish the icon set — maybe 2 hours of work. I'll push everything to the staging branch by 3 PM.",
                'offset_ms': 17500,
                'end_ms': 27000,
                'confidence': 0.88,
            },
            {
                'id': '60000006-0000-0000-0000-000000000003',
                'speaker_name': 'Bob Kumar',
                'text': "Perfect. I'll run the full regression suite tonight and we can do the production push first thing Thursday morning.",
                'offset_ms': 27500,
                'end_ms': 36000,
                'confidence': 0.91,
            },
            {
                'id': '60000006-0000-0000-0000-000000000004',
                'speaker_name': 'Carol Singh',
                'text': "What's the plan for the all-hands next week? Are we presenting the redesign?",
                'offset_ms': 120000,
                'end_ms': 127000,
                'confidence': 0.92,
            },
            {
                'id': '60000006-0000-0000-0000-000000000005',
                'speaker_name': 'Bob Kumar',
                'text': "I think Alice is handling that slide. We're probably doing a 5-minute teaser to generate excitement before the full launch.",
                'offset_ms': 127500,
                'end_ms': 137000,
                'confidence': 0.87,
            },
        ],
        'extractions': [
            {
                'id': '70000006-0001-0000-0000-000000000001',
                'utterance_idx': 1,
                'text': 'Carol to push icon set to staging branch by 3 PM',
                'kind': 'commitment',
                'owed_by_name': 'Carol Singh',
                'due_hint': '3 PM today',
                'status': 'accepted',
            },
            {
                'id': '70000006-0002-0000-0000-000000000002',
                'utterance_idx': 2,
                'text': 'Bob to run full regression suite tonight and push to production Thursday morning',
                'kind': 'commitment',
                'owed_by_name': 'Bob Kumar',
                'due_hint': 'Thursday morning',
                'status': 'accepted',
            },
        ],
    },
]

THREADS = [
    {
        'id': '80000001-0000-0000-0000-000000000001',
        'title': 'Mobile Redesign Initiative',
        'session_ids': [
            '50000001-0000-0000-0000-000000000001',
            '50000005-0000-0000-0000-000000000005',
        ],
    },
    {
        'id': '80000002-0000-0000-0000-000000000002',
        'title': 'Series B Fundraising',
        'session_ids': [
            '50000004-0000-0000-0000-000000000004',
        ],
    },
]


def _dt(iso_str):
    """Parse ISO datetime string to aware datetime."""
    return datetime.fromisoformat(iso_str.replace('Z', '+00:00'))


class Command(BaseCommand):
    help = 'Seed the database with mock data matching the Flutter app.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--reset',
            action='store_true',
            help='Delete existing seeded data before loading.',
        )

    def handle(self, *args, **options):
        if options['reset']:
            self.stdout.write('Deleting existing seeded data...')
            Session.objects.filter(is_seeded=True).delete()
            # Person objects are only deleted if they have no non-seeded sessions.
            # For simplicity in dev, delete all persons created by seed.
            seeded_names = {p['name'] for p in PEOPLE}
            Person.objects.filter(name__in=seeded_names).delete()
            self.stdout.write(self.style.WARNING('Seeded data cleared.'))

        # ---- People ----
        people_by_name: dict[str, Person] = {}
        for pdata in PEOPLE:
            person, created = Person.objects.get_or_create(
                id=uuid.UUID(pdata['id']),
                defaults={
                    'name': pdata['name'],
                    'role': pdata['role'],
                    'org': pdata['org'],
                    'avatar_color': pdata['avatar_color'],
                    'voiceprint_enrolled': pdata['voiceprint_enrolled'],
                },
            )
            people_by_name[person.name] = person
            verb = 'Created' if created else 'Already exists'
            self.stdout.write(f'  {verb}: Person {person.name}')

        # ---- Sessions + Utterances + Extractions ----
        for sdata in SESSIONS:
            session, created = Session.objects.get_or_create(
                id=uuid.UUID(sdata['id']),
                defaults={
                    'title': sdata['title'],
                    'summary': sdata['summary'],
                    'started_at': _dt(sdata['started_at']),
                    'duration_seconds': sdata['duration_seconds'],
                    'mode': sdata['mode'],
                    'location': sdata['location'],
                    'sync_state': sdata['sync_state'],
                    'is_private': sdata['is_private'],
                    'is_seeded': True,
                },
            )
            verb = 'Created' if created else 'Already exists'
            self.stdout.write(f'  {verb}: Session "{session.title}"')

            if created:
                # Add participants
                for name in sdata['participant_names']:
                    if name in people_by_name:
                        session.participants.add(people_by_name[name])

                # Create utterances (preserve order for extraction index lookup)
                utterance_objs = []
                for udata in sdata['utterances']:
                    speaker = people_by_name.get(udata['speaker_name'])
                    utterance = Utterance.objects.create(
                        id=uuid.UUID(udata['id']),
                        session=session,
                        speaker=speaker,
                        text=udata['text'],
                        offset_ms=udata['offset_ms'],
                        end_ms=udata.get('end_ms'),
                        confidence=udata.get('confidence'),
                    )
                    utterance_objs.append(utterance)

                # Create extractions
                for edata in sdata['extractions']:
                    utterance = utterance_objs[edata['utterance_idx']]
                    owed_by = people_by_name.get(edata['owed_by_name']) if edata['owed_by_name'] else None
                    Extraction.objects.create(
                        id=uuid.UUID(edata['id']),
                        session=session,
                        utterance=utterance,
                        text=edata['text'],
                        kind=edata['kind'],
                        owed_by=owed_by,
                        due_hint=edata['due_hint'],
                        status=edata['status'],
                    )

        # ---- Threads ----
        for tdata in THREADS:
            thread, created = Thread.objects.get_or_create(
                id=uuid.UUID(tdata['id']),
                defaults={'title': tdata['title']},
            )
            if created:
                for sid in tdata['session_ids']:
                    try:
                        session = Session.objects.get(id=uuid.UUID(sid))
                        thread.sessions.add(session)
                    except Session.DoesNotExist:
                        pass
            verb = 'Created' if created else 'Already exists'
            self.stdout.write(f'  {verb}: Thread "{thread.title}"')

        self.stdout.write(self.style.SUCCESS('\nSeed data loaded successfully.'))
        self.stdout.write(f'  People:      {Person.objects.count()}')
        self.stdout.write(f'  Sessions:    {Session.objects.count()}')
        self.stdout.write(f'  Utterances:  {Utterance.objects.count()}')
        self.stdout.write(f'  Extractions: {Extraction.objects.count()}')
        self.stdout.write(f'  Threads:     {Thread.objects.count()}')
