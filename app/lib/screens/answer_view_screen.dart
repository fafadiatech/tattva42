import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../mock/mock_data.dart';
import '../models/mock_answer.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';

class AnswerViewScreen extends ConsumerStatefulWidget {
  final String query;
  const AnswerViewScreen({super.key, required this.query});

  @override
  ConsumerState<AnswerViewScreen> createState() => _AnswerViewScreenState();
}

class _AnswerViewScreenState extends ConsumerState<AnswerViewScreen> {
  MockAnswer? _answer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final answer = await mockAnswer(widget.query);
    if (mounted) {
      setState(() {
        _answer = answer;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sessions = ref.watch(sessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer'),
        leading: BackButton(onPressed: () => context.go('/ask')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _answer == null
              ? const Center(child: Text('No answer available.'))
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Query echo
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 16, color: cs.outline),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.query,
                                      style: tt.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Answer card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  _answer!.answer,
                                  style: tt.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_answer!.citations.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Sources',
                            style: AppTextStyles.sectionCaption
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              final citation = _answer!.citations[i];
                              final session = sessions.maybeWhen(
                                data: (list) {
                                  try {
                                    return list.firstWhere(
                                        (s) => s.id == citation.sessionId);
                                  } catch (_) {
                                    return null;
                                  }
                                },
                                orElse: () => null,
                              );
                              return _CitationTile(
                                citation: citation,
                                sessionTitle: session?.title ?? citation.sessionId,
                                onTap: () => context.go(
                                  '/session/${citation.sessionId}/moment/${citation.utteranceId}',
                                ),
                              );
                            },
                            childCount: _answer!.citations.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _CitationTile extends StatelessWidget {
  final dynamic citation;
  final String sessionTitle;
  final VoidCallback onTap;

  const _CitationTile({
    required this.citation,
    required this.sessionTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.format_quote_outlined, size: 18, color: cs.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(sessionTitle,
                    style: AppTextStyles.statusLabel),
              ),
              Icon(Icons.chevron_right, size: 18, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
