import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../mock/mock_data.dart';
import '../models/session.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/session_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _search = '';
  CaptureMode? _filterMode;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => _showPeopleSheet(context),
            tooltip: 'People',
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          var filtered = sessions.where((s) {
            if (_filterMode != null && s.mode != _filterMode) return false;
            if (_search.isNotEmpty) {
              final q = _search.toLowerCase();
              return s.title.toLowerCase().contains(q) ||
                  s.summary.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          // Group by date
          final grouped = <String, List<Session>>{};
          for (final s in filtered) {
            final key = DateFormat('EEEE, d MMMM yyyy').format(s.startedAt);
            grouped.putIfAbsent(key, () => []).add(s);
          }

          return CustomScrollView(
            slivers: [
              // Search bar
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search sessions…',
                      prefixIcon: Icon(Icons.search_outlined),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filterMode == null,
                        onTap: () => setState(() => _filterMode = null),
                      ),
                      const SizedBox(width: 8),
                      ...CaptureMode.values.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: _modeLabel(m),
                          selected: _filterMode == m,
                          onTap: () => setState(
                              () => _filterMode = _filterMode == m ? null : m),
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: cs.outline),
                          const SizedBox(height: 16),
                          Text(
                            _search.isEmpty ? 'No sessions yet.' : 'No sessions matched "$_search".',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final keys = grouped.keys.toList();
                        final key = keys[i];
                        final group = grouped[key]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6, top: 4),
                              child: Text(key,
                                  style: tt.labelMedium?.merge(AppTextStyles.sectionHeading)
                                      .copyWith(color: cs.onSurfaceVariant)),
                            ),
                            ...group.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SessionCard(
                                session: s,
                                onTap: () => context.go('/library/session/${s.id}'),
                              ),
                            )),
                          ],
                        );
                      },
                      childCount: grouped.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _modeLabel(CaptureMode m) {
    switch (m) {
      case CaptureMode.meeting: return 'Meeting';
      case CaptureMode.ambient: return 'Ambient';
      case CaptureMode.dictation: return 'Dictation';
    }
  }

  void _showPeopleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _PeopleSheet(
        onPersonTap: (id) {
          Navigator.pop(context);
          context.go('/library/people/$id');
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.statusLabel.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PeopleSheet extends StatelessWidget {
  final void Function(String id) onPersonTap;
  const _PeopleSheet({required this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('People', style: tt.titleMedium?.merge(AppTextStyles.appBarTitle)),
          ),
          ...mockPeople.map((p) => ListTile(
            leading: CircleAvatar(
              backgroundColor: p.avatarColor.withAlpha(40),
              child: Text(p.name[0], style: AppTextStyles.avatarSmall.copyWith(color: p.avatarColor)),
            ),
            title: Text(p.name),
            subtitle: p.role != null ? Text('${p.role}${p.org != null ? " · ${p.org}" : ""}') : null,
            trailing: p.voiceprintEnrolled
                ? Icon(Icons.record_voice_over_outlined, size: 16, color: cs.primary)
                : null,
            onTap: () => onPersonTap(p.id),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
