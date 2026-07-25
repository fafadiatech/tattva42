import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/extractions_provider.dart';
import '../providers/player_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/utterances_provider.dart';
import '../models/extraction.dart';
import '../models/session.dart';
import '../theme/app_text_styles.dart';
import '../widgets/extraction_chip.dart';
import '../widgets/playback_controls.dart';
import '../widgets/utterance_row.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  String? _activeUtteranceId;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionByIdProvider(widget.sessionId));
    final utterances = ref.watch(utterancesBySessionProvider(widget.sessionId));
    final extractions = ref.watch(extractionsBySessionProvider(widget.sessionId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Session not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (session.isPrivate)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.lock_outline, size: 18, color: cs.outline),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Summary card
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryCard(session: session),
                  ),
                ),

                // Extractions
                if (extractions.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _ExtractionsSection(
                        extractions: extractions,
                        ref: ref,
                      ),
                    ),
                  ),

                // Transcript header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Transcript',
                      style: AppTextStyles.sectionCaption
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ),

                // Utterances
                if (utterances.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'No transcript available.',
                        style: TextStyle(color: cs.outline),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final u = utterances[i];
                        return UtteranceRow(
                          utterance: u,
                          isActive: _activeUtteranceId == u.id,
                          onTap: () => _onUtteranceTap(context, session, u.id, u.offset),
                        );
                      },
                      childCount: utterances.length,
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
              ],
            ),
          ),

          // Playback controls at bottom
          if (session.audioPath != null)
            PlaybackControls(audioPath: session.audioPath!),
        ],
      ),
    );
  }

  void _onUtteranceTap(
    BuildContext context,
    Session session,
    String utteranceId,
    Duration offset,
  ) {
    if (session.audioPath != null) {
      // Seek and play from this offset
      setState(() => _activeUtteranceId = utteranceId);
      ref.read(playerProvider.notifier).seekToOffset(offset);
    } else {
      // Navigate to moment view
      final base = GoRouterState.of(context).uri.path;
      if (base.startsWith('/library')) {
        context.go('/library/session/${session.id}/moment/$utteranceId');
      } else {
        context.go('/session/${session.id}/moment/$utteranceId');
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final Session session;
  const _SummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.summary, style: tt.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _MetaChip(
                  icon: Icons.access_time,
                  label: _fmt(session.duration),
                ),
                _MetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: _fmtDate(session.startedAt),
                ),
                if (session.location != null)
                  _MetaChip(
                    icon: Icons.place_outlined,
                    label: session.location!,
                  ),
                _MetaChip(
                  icon: _modeIcon(session.mode),
                  label: _modeLabel(session.mode),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _modeIcon(CaptureMode m) {
    switch (m) {
      case CaptureMode.meeting: return Icons.groups_outlined;
      case CaptureMode.ambient: return Icons.hearing_outlined;
      case CaptureMode.dictation: return Icons.record_voice_over_outlined;
    }
  }

  String _modeLabel(CaptureMode m) {
    switch (m) {
      case CaptureMode.meeting: return 'Meeting';
      case CaptureMode.ambient: return 'Ambient';
      case CaptureMode.dictation: return 'Dictation';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.outline),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.metaLabel.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ExtractionsSection extends StatelessWidget {
  final List<Extraction> extractions;
  final WidgetRef ref;
  const _ExtractionsSection({required this.extractions, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extractions',
          style: AppTextStyles.sectionCaption
              .copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          children: extractions.map((e) => ExtractionChip(
            extraction: e,
            onAccept: e.status == ExtractionStatus.pending
                ? () => ref.read(extractionsProvider.notifier).updateStatus(e.id, ExtractionStatus.accepted)
                : null,
            onDismiss: e.status == ExtractionStatus.pending
                ? () => ref.read(extractionsProvider.notifier).updateStatus(e.id, ExtractionStatus.dismissed)
                : null,
          )).toList(),
        ),
      ],
    );
  }
}
