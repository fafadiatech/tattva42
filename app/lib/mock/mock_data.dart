import 'package:flutter/material.dart';

import '../models/citation.dart';
import '../models/extraction.dart';
import '../models/mock_answer.dart';
import '../models/person.dart';
import '../models/session.dart';
import '../models/thread.dart';
import '../models/utterance.dart';

// ---------------------------------------------------------------------------
// People
// ---------------------------------------------------------------------------

const List<Person> mockPeople = [
  Person(
    id: 'p_sidharth',
    name: 'Sidharth Shah',
    role: 'Founder',
    org: 'Fafadia Tech',
    avatarColor: Color(0xFF006B5D),
    voiceprintEnrolled: true,
  ),
  Person(
    id: 'p_priya',
    name: 'Priya Menon',
    role: 'Product Lead',
    org: 'Fafadia Tech',
    avatarColor: Color(0xFF7B4F9E),
    voiceprintEnrolled: false,
  ),
  Person(
    id: 'p_rahul',
    name: 'Rahul Desai',
    role: 'Engineering Lead',
    org: 'Fafadia Tech',
    avatarColor: Color(0xFFB5560F),
    voiceprintEnrolled: false,
  ),
  Person(
    id: 'p_ananya',
    name: 'Ananya Krishnan',
    role: 'Design',
    org: 'Fafadia Tech',
    avatarColor: Color(0xFF1A6E8E),
    voiceprintEnrolled: false,
  ),
  Person(
    id: 'p_vikram',
    name: 'Vikram Nair',
    role: 'Client',
    org: 'UrbanGrid Solutions',
    avatarColor: Color(0xFF5C5C00),
    voiceprintEnrolled: false,
  ),
];

// ---------------------------------------------------------------------------
// Sessions  (3 days: Mon–Wed of a working week)
// ---------------------------------------------------------------------------

final List<Session> mockSessions = [
  // Monday morning stand-up
  Session(
    id: 's_standup_mon',
    title: 'Monday stand-up',
    summary:
        'Team aligned on sprint goals. Rahul flagged a blocker on the auth service. Priya will chase the design sign-off from Ananya by EOD.',
    startedAt: DateTime(2026, 7, 20, 9, 30),
    duration: const Duration(minutes: 18),
    mode: CaptureMode.meeting,
    location: 'Conference room B',
    participantIds: ['p_sidharth', 'p_priya', 'p_rahul', 'p_ananya'],
    syncState: SyncState.synced,
    isPrivate: false,
    audioPath: null,
    isSeeded: true,
  ),

  // Monday afternoon — client call
  Session(
    id: 's_client_mon',
    title: 'UrbanGrid product demo',
    summary:
        'Demoed the new dashboard to Vikram. He loved the heat-map feature but asked for CSV export by next sprint. Budget increase of 15% was discussed pending formal sign-off.',
    startedAt: DateTime(2026, 7, 20, 14, 0),
    duration: const Duration(minutes: 42),
    mode: CaptureMode.meeting,
    location: 'Google Meet',
    participantIds: ['p_sidharth', 'p_priya', 'p_vikram'],
    syncState: SyncState.synced,
    isPrivate: false,
    audioPath: null,
    isSeeded: true,
  ),

  // Tuesday morning — site visit (ambient)
  Session(
    id: 's_site_tue',
    title: 'Site visit — UrbanGrid HQ',
    summary:
        'Walked the ops floor with Vikram. Noted network latency issues on floor 3. Discussed placement of edge nodes. Took photos of the server room layout.',
    startedAt: DateTime(2026, 7, 21, 10, 15),
    duration: const Duration(minutes: 65),
    mode: CaptureMode.ambient,
    location: 'UrbanGrid HQ, Koramangala',
    participantIds: ['p_sidharth', 'p_vikram'],
    syncState: SyncState.synced,
    isPrivate: false,
    audioPath: null,
    isSeeded: true,
  ),

  // Tuesday corridor chat
  Session(
    id: 's_corridor_tue',
    title: 'Quick chat with Rahul',
    summary:
        'Rahul confirmed the auth blocker is resolved. He needs one more day for the token refresh logic. We agreed to skip the regression test run for the hotfix branch.',
    startedAt: DateTime(2026, 7, 21, 16, 45),
    duration: const Duration(minutes: 7),
    mode: CaptureMode.ambient,
    location: null,
    participantIds: ['p_sidharth', 'p_rahul'],
    syncState: SyncState.local,
    isPrivate: false,
    audioPath: null,
    isSeeded: true,
  ),

  // Wednesday design review
  Session(
    id: 's_design_wed',
    title: 'Design review — onboarding flow',
    summary:
        'Reviewed Ananya\'s revised onboarding screens. Three screens approved as-is. The permissions screen needs a copy change. Decided to drop the optional avatar step from v1.',
    startedAt: DateTime(2026, 7, 22, 11, 0),
    duration: const Duration(minutes: 35),
    mode: CaptureMode.meeting,
    location: 'Studio',
    participantIds: ['p_sidharth', 'p_priya', 'p_ananya'],
    syncState: SyncState.synced,
    isPrivate: false,
    audioPath: null,
    isSeeded: true,
  ),

  // Wednesday evening — dictated note
  Session(
    id: 's_dictation_wed',
    title: 'Evening reflection',
    summary:
        'Personal note: ideas for the tattva product roadmap — voice-first capture, AI extraction, and a graph view for connected sessions.',
    startedAt: DateTime(2026, 7, 22, 19, 30),
    duration: const Duration(minutes: 4),
    mode: CaptureMode.dictation,
    location: null,
    participantIds: ['p_sidharth'],
    syncState: SyncState.local,
    isPrivate: true,
    audioPath: null,
    isSeeded: true,
  ),
];

// ---------------------------------------------------------------------------
// Utterances
// ---------------------------------------------------------------------------

final List<Utterance> mockUtterances = [
  // --- Monday stand-up (s_standup_mon) ---
  Utterance(
    id: 'u_sm_01',
    sessionId: 's_standup_mon',
    speakerId: 'p_sidharth',
    text: 'Good morning everyone. Let\'s keep this quick — I want us out in fifteen minutes.',
    offset: Duration.zero,
    end: const Duration(seconds: 5),
    confidence: 0.97,
  ),
  Utterance(
    id: 'u_sm_02',
    sessionId: 's_standup_mon',
    speakerId: 'p_rahul',
    text: 'I\'m blocked on the auth service. The token refresh endpoint is throwing a 401 on every cold start.',
    offset: const Duration(seconds: 6),
    end: const Duration(seconds: 12),
    confidence: 0.95,
  ),
  Utterance(
    id: 'u_sm_03',
    sessionId: 's_standup_mon',
    speakerId: 'p_priya',
    text: 'I\'ll chase the design sign-off from Ananya today — she should have it ready by end of day.',
    offset: const Duration(seconds: 13),
    end: const Duration(seconds: 20),
    confidence: 0.94,
  ),
  Utterance(
    id: 'u_sm_04',
    sessionId: 's_standup_mon',
    speakerId: 'p_ananya',
    text: 'Yes, I\'ll send the final screens by four. Just need to adjust the spacing on the permissions modal.',
    offset: const Duration(seconds: 21),
    end: const Duration(seconds: 28),
    confidence: 0.93,
  ),
  Utterance(
    id: 'u_sm_05',
    sessionId: 's_standup_mon',
    speakerId: 'p_sidharth',
    text: 'Rahul, can you unblock yourself today or do you need the whole sprint buffer?',
    offset: const Duration(seconds: 29),
    end: const Duration(seconds: 35),
    confidence: 0.98,
  ),
  Utterance(
    id: 'u_sm_06',
    sessionId: 's_standup_mon',
    speakerId: 'p_rahul',
    text: 'Give me until tomorrow morning. I think it\'s a missing header in the refresh request.',
    offset: const Duration(seconds: 36),
    end: const Duration(seconds: 43),
    confidence: 0.92,
  ),
  Utterance(
    id: 'u_sm_07',
    sessionId: 's_standup_mon',
    speakerId: 'p_sidharth',
    text: 'Alright. Sprint goal stays the same — ship the dashboard MVP by Thursday.',
    offset: const Duration(seconds: 44),
    end: const Duration(seconds: 50),
    confidence: 0.97,
  ),

  // --- Monday client call (s_client_mon) ---
  Utterance(
    id: 'u_cm_01',
    sessionId: 's_client_mon',
    speakerId: 'p_vikram',
    text: 'The heat-map overlay is exactly what we needed. Our ops team will love this.',
    offset: const Duration(minutes: 5, seconds: 10),
    end: const Duration(minutes: 5, seconds: 17),
    confidence: 0.96,
  ),
  Utterance(
    id: 'u_cm_02',
    sessionId: 's_client_mon',
    speakerId: 'p_sidharth',
    text: 'Thank you. We spent a lot of time on the color ramp — it needed to be readable in direct sunlight on tablets.',
    offset: const Duration(minutes: 5, seconds: 18),
    end: const Duration(minutes: 5, seconds: 27),
    confidence: 0.95,
  ),
  Utterance(
    id: 'u_cm_03',
    sessionId: 's_client_mon',
    speakerId: 'p_vikram',
    text: 'One thing we really need is a CSV export. Our finance team won\'t use a dashboard that can\'t export data.',
    offset: const Duration(minutes: 8, seconds: 0),
    end: const Duration(minutes: 8, seconds: 9),
    confidence: 0.97,
  ),
  Utterance(
    id: 'u_cm_04',
    sessionId: 's_client_mon',
    speakerId: 'p_priya',
    text: 'We can add CSV export in the next sprint. I\'ll add it to the backlog right now.',
    offset: const Duration(minutes: 8, seconds: 10),
    end: const Duration(minutes: 8, seconds: 17),
    confidence: 0.94,
  ),
  Utterance(
    id: 'u_cm_05',
    sessionId: 's_client_mon',
    speakerId: 'p_vikram',
    text: 'On the commercial side, we\'re looking at a fifteen percent budget increase. I can get formal sign-off from our CFO by Friday.',
    offset: const Duration(minutes: 22, seconds: 5),
    end: const Duration(minutes: 22, seconds: 16),
    confidence: 0.91,
  ),
  Utterance(
    id: 'u_cm_06',
    sessionId: 's_client_mon',
    speakerId: 'p_sidharth',
    text: 'That\'s great news. We\'ll hold the change order until you confirm.',
    offset: const Duration(minutes: 22, seconds: 17),
    end: const Duration(minutes: 22, seconds: 23),
    confidence: 0.97,
  ),

  // --- Tuesday site visit (s_site_tue) ---
  Utterance(
    id: 'u_st_01',
    sessionId: 's_site_tue',
    speakerId: 'p_vikram',
    text: 'Floor three is where we\'ve been seeing latency spikes — sometimes up to eight hundred milliseconds.',
    offset: const Duration(minutes: 12, seconds: 30),
    end: const Duration(minutes: 12, seconds: 38),
    confidence: 0.89,
  ),
  Utterance(
    id: 'u_st_02',
    sessionId: 's_site_tue',
    speakerId: 'p_sidharth',
    text: 'Is the switch in the comms room on this floor? We might need to place an edge node here.',
    offset: const Duration(minutes: 12, seconds: 39),
    end: const Duration(minutes: 12, seconds: 47),
    confidence: 0.93,
  ),
  Utterance(
    id: 'u_st_03',
    sessionId: 's_site_tue',
    speakerId: 'p_vikram',
    text: 'Yes, it\'s a ten-year-old Cisco unit. We\'re replacing it in Q3 anyway.',
    offset: const Duration(minutes: 12, seconds: 48),
    end: const Duration(minutes: 12, seconds: 55),
    confidence: 0.90,
  ),
  Utterance(
    id: 'u_st_04',
    sessionId: 's_site_tue',
    speakerId: 'p_sidharth',
    text: 'Let\'s plan for two edge nodes on this floor. I\'ll factor that into the infra estimate.',
    offset: const Duration(minutes: 13, seconds: 0),
    end: const Duration(minutes: 13, seconds: 8),
    confidence: 0.95,
  ),

  // --- Tuesday corridor (s_corridor_tue) ---
  Utterance(
    id: 'u_ct_01',
    sessionId: 's_corridor_tue',
    speakerId: 'p_rahul',
    text: 'Hey, just wanted to let you know — the auth blocker is fixed. It was a missing Authorization header on the refresh call.',
    offset: Duration.zero,
    end: const Duration(seconds: 8),
    confidence: 0.96,
  ),
  Utterance(
    id: 'u_ct_02',
    sessionId: 's_corridor_tue',
    speakerId: 'p_sidharth',
    text: 'Nice. How long for the token refresh logic?',
    offset: const Duration(seconds: 9),
    end: const Duration(seconds: 13),
    confidence: 0.98,
  ),
  Utterance(
    id: 'u_ct_03',
    sessionId: 's_corridor_tue',
    speakerId: 'p_rahul',
    text: 'One more day. And for the hotfix branch — can we skip the regression run? It\'s just a two-line fix.',
    offset: const Duration(seconds: 14),
    end: const Duration(seconds: 22),
    confidence: 0.93,
  ),
  Utterance(
    id: 'u_ct_04',
    sessionId: 's_corridor_tue',
    speakerId: 'p_sidharth',
    text: 'Agreed. Skip regression for the hotfix. But make sure the unit tests still pass.',
    offset: const Duration(seconds: 23),
    end: const Duration(seconds: 30),
    confidence: 0.97,
  ),

  // --- Wednesday design review (s_design_wed) ---
  Utterance(
    id: 'u_dw_01',
    sessionId: 's_design_wed',
    speakerId: 'p_ananya',
    text: 'I\'ve revised the onboarding flow based on the feedback from last week. There are now six screens down from nine.',
    offset: Duration.zero,
    end: const Duration(seconds: 8),
    confidence: 0.95,
  ),
  Utterance(
    id: 'u_dw_02',
    sessionId: 's_design_wed',
    speakerId: 'p_priya',
    text: 'The first three screens look great — approved as-is.',
    offset: const Duration(seconds: 9),
    end: const Duration(seconds: 14),
    confidence: 0.97,
  ),
  Utterance(
    id: 'u_dw_03',
    sessionId: 's_design_wed',
    speakerId: 'p_sidharth',
    text: 'The permissions screen copy needs work. "Allow access" is too vague — we need to tell users exactly why.',
    offset: const Duration(seconds: 15),
    end: const Duration(seconds: 24),
    confidence: 0.96,
  ),
  Utterance(
    id: 'u_dw_04',
    sessionId: 's_design_wed',
    speakerId: 'p_ananya',
    text: 'I\'ll rewrite the permissions copy with specific use cases. Give me until tomorrow.',
    offset: const Duration(seconds: 25),
    end: const Duration(seconds: 32),
    confidence: 0.94,
  ),
  Utterance(
    id: 'u_dw_05',
    sessionId: 's_design_wed',
    speakerId: 'p_priya',
    text: 'Shall we drop the optional avatar step? It adds friction and we can add it post-launch.',
    offset: const Duration(seconds: 33),
    end: const Duration(seconds: 41),
    confidence: 0.95,
  ),
  Utterance(
    id: 'u_dw_06',
    sessionId: 's_design_wed',
    speakerId: 'p_sidharth',
    text: 'Agreed. Drop the avatar step from version one. We can revisit in the next cycle.',
    offset: const Duration(seconds: 42),
    end: const Duration(seconds: 49),
    confidence: 0.98,
  ),

  // --- Wednesday dictation (s_dictation_wed) ---
  Utterance(
    id: 'u_dic_01',
    sessionId: 's_dictation_wed',
    speakerId: 'p_sidharth',
    text: 'Thinking about the tattva roadmap. Voice-first capture is the core. Everything else — search, extraction, graph — builds on top of that.',
    offset: Duration.zero,
    end: const Duration(seconds: 10),
    confidence: 0.96,
  ),
  Utterance(
    id: 'u_dic_02',
    sessionId: 's_dictation_wed',
    speakerId: 'p_sidharth',
    text: 'AI extraction should surface commitments and decisions automatically. No tagging required from the user.',
    offset: const Duration(seconds: 11),
    end: const Duration(seconds: 20),
    confidence: 0.97,
  ),
  Utterance(
    id: 'u_dic_03',
    sessionId: 's_dictation_wed',
    speakerId: 'p_sidharth',
    text: 'The graph view — sessions as nodes, shared participants or topics as edges. That\'s the second brain metaphor made visible.',
    offset: const Duration(seconds: 21),
    end: const Duration(seconds: 31),
    confidence: 0.95,
  ),
];

// ---------------------------------------------------------------------------
// Extractions
// ---------------------------------------------------------------------------

final List<Extraction> mockExtractions = [
  Extraction(
    id: 'e_01',
    sessionId: 's_standup_mon',
    utteranceId: 'u_sm_03',
    text: 'Priya to get design sign-off from Ananya by end of day Monday.',
    kind: ExtractionKind.commitment,
    owedBy: 'p_priya',
    dueHint: 'Monday EOD',
    status: ExtractionStatus.accepted,
  ),
  Extraction(
    id: 'e_02',
    sessionId: 's_standup_mon',
    utteranceId: 'u_sm_07',
    text: 'Ship dashboard MVP by Thursday.',
    kind: ExtractionKind.decision,
    owedBy: null,
    dueHint: 'Thursday',
    status: ExtractionStatus.accepted,
  ),
  Extraction(
    id: 'e_03',
    sessionId: 's_client_mon',
    utteranceId: 'u_cm_04',
    text: 'Add CSV export feature in next sprint.',
    kind: ExtractionKind.commitment,
    owedBy: 'p_priya',
    dueHint: 'Next sprint',
    status: ExtractionStatus.pending,
  ),
  Extraction(
    id: 'e_04',
    sessionId: 's_client_mon',
    utteranceId: 'u_cm_05',
    text: 'UrbanGrid budget increase of 15% — formal sign-off from CFO by Friday.',
    kind: ExtractionKind.figure,
    owedBy: 'p_vikram',
    dueHint: 'Friday',
    status: ExtractionStatus.pending,
  ),
  Extraction(
    id: 'e_05',
    sessionId: 's_site_tue',
    utteranceId: 'u_st_04',
    text: 'Plan for two edge nodes on floor 3 of UrbanGrid HQ.',
    kind: ExtractionKind.decision,
    owedBy: 'p_sidharth',
    dueHint: null,
    status: ExtractionStatus.accepted,
  ),
  Extraction(
    id: 'e_06',
    sessionId: 's_corridor_tue',
    utteranceId: 'u_ct_04',
    text: 'Skip regression run for hotfix branch; unit tests must still pass.',
    kind: ExtractionKind.decision,
    owedBy: null,
    dueHint: null,
    status: ExtractionStatus.accepted,
  ),
  Extraction(
    id: 'e_07',
    sessionId: 's_design_wed',
    utteranceId: 'u_dw_04',
    text: 'Ananya to rewrite permissions screen copy with specific use cases.',
    kind: ExtractionKind.commitment,
    owedBy: 'p_ananya',
    dueHint: 'Thursday',
    status: ExtractionStatus.pending,
  ),
  Extraction(
    id: 'e_08',
    sessionId: 's_design_wed',
    utteranceId: 'u_dw_06',
    text: 'Drop optional avatar step from version one of onboarding.',
    kind: ExtractionKind.decision,
    owedBy: null,
    dueHint: null,
    status: ExtractionStatus.accepted,
  ),
  Extraction(
    id: 'e_09',
    sessionId: 's_dictation_wed',
    utteranceId: 'u_dic_01',
    text: 'Voice-first capture is the core of the tattva roadmap.',
    kind: ExtractionKind.decision,
    owedBy: null,
    dueHint: null,
    status: ExtractionStatus.pending,
  ),
  Extraction(
    id: 'e_10',
    sessionId: 's_standup_mon',
    utteranceId: 'u_sm_02',
    text: 'What is causing the 401 on token refresh cold start?',
    kind: ExtractionKind.question,
    owedBy: 'p_rahul',
    dueHint: null,
    status: ExtractionStatus.dismissed,
  ),
];

// ---------------------------------------------------------------------------
// Threads
// ---------------------------------------------------------------------------

final List<Thread> mockThreads = [
  Thread(
    id: 't_urbangrid',
    title: 'UrbanGrid project',
    sessionIds: ['s_client_mon', 's_site_tue'],
  ),
  Thread(
    id: 't_auth',
    title: 'Auth service blocker',
    sessionIds: ['s_standup_mon', 's_corridor_tue'],
  ),
  Thread(
    id: 't_onboarding',
    title: 'Onboarding design',
    sessionIds: ['s_standup_mon', 's_design_wed'],
  ),
];

// ---------------------------------------------------------------------------
// Canned Q&A + mock answer function
// ---------------------------------------------------------------------------

final _cannedAnswers = <String, MockAnswer>{
  'csv export': const MockAnswer(
    answer:
        'CSV export came up during the UrbanGrid product demo on Monday. Vikram specifically said his finance team won\'t use a dashboard that can\'t export data. Priya committed to adding it in the next sprint.',
    citations: [
      Citation(sessionId: 's_client_mon', utteranceId: 'u_cm_03'),
      Citation(sessionId: 's_client_mon', utteranceId: 'u_cm_04'),
    ],
  ),
  'budget': const MockAnswer(
    answer:
        'Vikram mentioned a 15% budget increase for UrbanGrid during the Monday demo call. He said he can get formal CFO sign-off by Friday.',
    citations: [
      Citation(sessionId: 's_client_mon', utteranceId: 'u_cm_05'),
      Citation(sessionId: 's_client_mon', utteranceId: 'u_cm_06'),
    ],
  ),
  'auth': const MockAnswer(
    answer:
        'Rahul raised an auth service blocker at Monday\'s stand-up — a 401 on every cold start due to a missing Authorization header on the token refresh call. He resolved it by Tuesday afternoon and confirmed in a quick corridor chat.',
    citations: [
      Citation(sessionId: 's_standup_mon', utteranceId: 'u_sm_02'),
      Citation(sessionId: 's_corridor_tue', utteranceId: 'u_ct_01'),
    ],
  ),
  'edge node': const MockAnswer(
    answer:
        'During the UrbanGrid site visit on Tuesday, you and Vikram found latency spikes of up to 800ms on floor 3. You decided to plan for two edge nodes on that floor; the current Cisco switch is being replaced in Q3.',
    citations: [
      Citation(sessionId: 's_site_tue', utteranceId: 'u_st_01'),
      Citation(sessionId: 's_site_tue', utteranceId: 'u_st_04'),
    ],
  ),
  'onboarding': const MockAnswer(
    answer:
        'Wednesday\'s design review approved three of six onboarding screens outright. The permissions screen needs copy rewrite by Ananya. The optional avatar step was dropped from version one.',
    citations: [
      Citation(sessionId: 's_design_wed', utteranceId: 'u_dw_02'),
      Citation(sessionId: 's_design_wed', utteranceId: 'u_dw_03'),
      Citation(sessionId: 's_design_wed', utteranceId: 'u_dw_06'),
    ],
  ),
  'roadmap': const MockAnswer(
    answer:
        'Your Wednesday evening dictation outlines the tattva roadmap: voice-first capture as the core, with AI extraction surfacing commitments and decisions automatically, and a graph view connecting sessions by participants or topics.',
    citations: [
      Citation(sessionId: 's_dictation_wed', utteranceId: 'u_dic_01'),
      Citation(sessionId: 's_dictation_wed', utteranceId: 'u_dic_02'),
      Citation(sessionId: 's_dictation_wed', utteranceId: 'u_dic_03'),
    ],
  ),
};

Future<MockAnswer> mockAnswer(String query) async {
  final q = query.toLowerCase();

  // Check canned answers
  for (final entry in _cannedAnswers.entries) {
    if (q.contains(entry.key)) {
      await Future.delayed(const Duration(milliseconds: 700));
      return entry.value;
    }
  }

  // Generic: count matching utterances
  final matched = mockUtterances.where((u) {
    final words = q.split(RegExp(r'\s+'));
    return words.any((w) => w.length > 2 && u.text.toLowerCase().contains(w));
  }).toList();

  await Future.delayed(const Duration(milliseconds: 300));

  if (matched.isEmpty) {
    return const MockAnswer(
      answer: 'No moments matched your query. Try asking about CSV export, the auth blocker, UrbanGrid budget, edge nodes, onboarding, or the product roadmap.',
      citations: [],
    );
  }

  return MockAnswer(
    answer: '${matched.length} moment${matched.length == 1 ? '' : 's'} matched your query across ${matched.map((u) => u.sessionId).toSet().length} session${matched.map((u) => u.sessionId).toSet().length == 1 ? '' : 's'}.',
    citations: matched
        .take(5)
        .map((u) => Citation(sessionId: u.sessionId, utteranceId: u.id))
        .toList(),
  );
}
