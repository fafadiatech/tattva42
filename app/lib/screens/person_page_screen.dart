import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../mock/mock_data.dart';
import '../models/person.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/session_card.dart';

class PersonPageScreen extends ConsumerWidget {
  final String personId;
  const PersonPageScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Person? person = mockPeople.where((p) => p.id == personId).firstOrNull;
    final sessionsAsync = ref.watch(sessionsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (person == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Person not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          final personSessions = sessions
              .where((s) => s.participantIds.contains(personId))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _PersonHeader(person: person),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Sessions together',
                    style: AppTextStyles.sectionCaption
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              if (personSessions.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'No sessions with ${person.name} yet.',
                      style: TextStyle(color: cs.outline),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SessionCard(
                          session: personSessions[i],
                          onTap: () => context.go(
                              '/library/session/${personSessions[i].id}'),
                        ),
                      ),
                      childCount: personSessions.length,
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

class _PersonHeader extends StatelessWidget {
  final Person person;
  const _PersonHeader({required this.person});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: person.avatarColor.withAlpha(40),
            child: Text(
              person.name[0],
              style: AppTextStyles.avatarLarge.copyWith(color: person.avatarColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(person.name, style: tt.titleLarge?.merge(AppTextStyles.appBarTitle)),
          if (person.role != null)
            Text(
              '${person.role}${person.org != null ? " · ${person.org}" : ""}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          if (person.voiceprintEnrolled) ...[
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(Icons.record_voice_over_outlined, size: 14, color: cs.primary),
              label: const Text('Voiceprint enrolled'),
              backgroundColor: cs.primaryContainer.withAlpha(80),
            ),
          ],
        ],
      ),
    );
  }
}
