import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/extraction.dart';
import '../providers/extractions_provider.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/extraction_chip.dart';
import '../widgets/session_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final extractionsAsync = ref.watch(extractionsProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final dayLabel = DateFormat('EEEE, d MMMM').format(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(dayLabel,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ),
          ),
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          // Show sessions from the last 24h (or all mock sessions if no real ones today)
          final cutoff = today.subtract(const Duration(hours: 24));
          var todaySessions = sessions.where((s) => s.startedAt.isAfter(cutoff)).toList();
          if (todaySessions.isEmpty) {
            // Show last 3 seeded sessions for demo purposes
            todaySessions = sessions.take(3).toList();
          }

          // Pending extractions
          final pendingExtractions = extractionsAsync.maybeWhen(
            data: (list) =>
                list.where((e) => e.status == ExtractionStatus.pending).toList(),
            orElse: () => <Extraction>[],
          );

          return CustomScrollView(
            slivers: [
              if (pendingExtractions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _PendingExtractionsSection(
                    extractions: pendingExtractions,
                    ref: ref,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Text('Sessions',
                    style: AppTextStyles.sectionCaption
                        .copyWith(color: cs.onSurfaceVariant)),
                ),
              ),
              if (todaySessions.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                    icon: Icons.mic_none_outlined,
                    message: 'No recordings yet today.\nTap the bar below to start capturing.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SessionCard(
                          session: todaySessions[i],
                          onTap: () => context.go('/session/${todaySessions[i].id}'),
                        ),
                      ),
                      childCount: todaySessions.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PendingExtractionsSection extends StatelessWidget {
  final List<Extraction> extractions;
  final WidgetRef ref;
  const _PendingExtractionsSection({required this.extractions, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Needs attention',
            style: AppTextStyles.sectionCaption
                .copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ...extractions.take(6).map((e) => ExtractionChip(
            extraction: e,
            onAccept: () => ref
                .read(extractionsProvider.notifier)
                .updateStatus(e.id, ExtractionStatus.accepted),
            onDismiss: () => ref
                .read(extractionsProvider.notifier)
                .updateStatus(e.id, ExtractionStatus.dismissed),
          )),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
