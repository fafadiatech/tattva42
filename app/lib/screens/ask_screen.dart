import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_text_styles.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _focused = false;

  static const _suggestions = [
    'What was decided about the CSV export?',
    'What is the budget increase from UrbanGrid?',
    'What happened with the auth blocker?',
    'What did we decide about the edge nodes?',
    'What was agreed in the onboarding review?',
    'What is on the tattva roadmap?',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (query.trim().isEmpty) return;
    _focusNode.unfocus();
    context.go('/ask/answer?q=${Uri.encodeComponent(query.trim())}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask', style: AppTextStyles.appBarTitle),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(_focused ? 16 : 12),
                  border: Border.all(
                    color: _focused ? cs.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: _focused ? 8 : 0,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: _focused ? 4 : 1,
                  minLines: 1,
                  textInputAction: _focused ? TextInputAction.newline : TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: _focused
                        ? 'What do you want to know about your sessions?'
                        : 'Ask anything about your sessions…',
                    prefixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        _focused ? Icons.auto_awesome_outlined : Icons.search_outlined,
                        key: ValueKey(_focused),
                        color: _focused ? cs.primary : null,
                      ),
                    ),
                    suffixIcon: _focused
                        ? IconButton(
                            icon: Icon(Icons.send_rounded, color: cs.primary),
                            onPressed: () => _submit(_controller.text),
                            tooltip: 'Ask',
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: _submit,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Try asking',
                style: AppTextStyles.sectionCaption
                    .copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _SuggestionTile(
                  text: _suggestions[i],
                  onTap: () => _submit(_suggestions[i]),
                ),
                childCount: _suggestions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: cs.secondary),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              Icon(Icons.chevron_right, size: 18, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}
