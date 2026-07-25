import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_text_styles.dart';

import 'providers/recorder_provider.dart';
import 'screens/ask_screen.dart';
import 'screens/answer_view_screen.dart';
import 'screens/audio_spike_screen.dart';
import 'screens/library_screen.dart';
import 'screens/moment_view_screen.dart';
import 'screens/person_page_screen.dart';
import 'screens/privacy_centre_screen.dart';
import 'screens/session_detail_screen.dart';
import 'screens/today_screen.dart';
import 'screens/you_screen.dart';
import 'widgets/live_capture_sheet.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _todayKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _askKey = GlobalKey<NavigatorState>(debugLabel: 'ask');
final _libraryKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final _youKey = GlobalKey<NavigatorState>(debugLabel: 'you');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) {
        return _AppShell(shell: shell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _todayKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (ctx, _) => const TodayScreen(),
              routes: [
                GoRoute(
                  path: 'session/:id',
                  builder: (_, state) =>
                      SessionDetailScreen(sessionId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'moment/:utteranceId',
                      builder: (_, state) => MomentViewScreen(
                        sessionId: state.pathParameters['id']!,
                        utteranceId: state.pathParameters['utteranceId']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _askKey,
          routes: [
            GoRoute(
              path: '/ask',
              builder: (ctx, _) => const AskScreen(),
              routes: [
                GoRoute(
                  path: 'answer',
                  builder: (_, state) => AnswerViewScreen(
                    query: state.uri.queryParameters['q'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _libraryKey,
          routes: [
            GoRoute(
              path: '/library',
              builder: (ctx, _) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'session/:id',
                  builder: (_, state) =>
                      SessionDetailScreen(sessionId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'moment/:utteranceId',
                      builder: (_, state) => MomentViewScreen(
                        sessionId: state.pathParameters['id']!,
                        utteranceId: state.pathParameters['utteranceId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'people/:id',
                  builder: (_, state) =>
                      PersonPageScreen(personId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _youKey,
          routes: [
            GoRoute(
              path: '/you',
              builder: (ctx, _) => const YouScreen(),
              routes: [
                GoRoute(
                  path: 'privacy',
                  builder: (ctx, _) => const PrivacyCentreScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Hidden spike route — outside shell
    GoRoute(
      path: '/spike',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (ctx, _) => const AudioSpikeScreen(),
    ),
  ],
);

// ─── Shell ────────────────────────────────────────────────────────────────────

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _AppShell({required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorder = ref.watch(recorderProvider);

    // Only show the FAB on the root tab screens. Sub-routes (session detail,
    // answer view, etc.) have their own bottom controls; the FAB would overlap.
    final location = GoRouterState.of(context).uri.path;
    const _rootPaths = {'/', '/ask', '/library', '/you'};
    final isRootTab = _rootPaths.contains(location);

    return Scaffold(
      body: shell,
      floatingActionButton: isRootTab ? _RecordFab(recorder: recorder) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
      ),
    );
  }
}

// ─── Hero record FAB ─────────────────────────────────────────────────────────

class _RecordFab extends StatelessWidget {
  final RecorderState recorder;
  const _RecordFab({required this.recorder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget child;
    Color bgColor;

    switch (recorder.status) {
      case RecordingStatus.recording:
        bgColor = cs.error;
        child = const _PulsingMicIcon();
      case RecordingStatus.paused:
        bgColor = cs.tertiary;
        child = const Icon(Icons.pause, size: 28);
      case RecordingStatus.processing:
        bgColor = cs.secondary;
        child = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: cs.onSecondary,
          ),
        );
      case RecordingStatus.idle:
      case RecordingStatus.stopped:
        bgColor = cs.primary;
        child = const Icon(Icons.mic, size: 28);
    }

    return FloatingActionButton.large(
      onPressed: () => _openSheet(context),
      backgroundColor: bgColor,
      foregroundColor: cs.onPrimary,
      elevation: 3,
      tooltip: 'Record',
      child: child,
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const LiveCaptureSheet(),
    );
  }
}

class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon();

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Icon(Icons.mic, size: 28),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const _BottomBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _leftDests = [
    _NavDest(icon: Icons.wb_sunny_outlined, selectedIcon: Icons.wb_sunny, label: 'Today', index: 0),
    _NavDest(icon: Icons.search_outlined, selectedIcon: Icons.search, label: 'Ask', index: 1),
  ];

  static const _rightDests = [
    _NavDest(icon: Icons.library_books_outlined, selectedIcon: Icons.library_books, label: 'Library', index: 2),
    _NavDest(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'You', index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BottomAppBar(
      color: cs.surfaceContainer,
      elevation: 3,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          ..._leftDests.map((d) => _NavItem(
                dest: d,
                selected: selectedIndex == d.index,
                onTap: () => onDestinationSelected(d.index),
              )),
          // Spacer for the FAB notch
          const Expanded(child: SizedBox()),
          ..._rightDests.map((d) => _NavItem(
                dest: d,
                selected: selectedIndex == d.index,
                onTap: () => onDestinationSelected(d.index),
              )),
        ],
      ),
    );
  }
}

class _NavDest {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  const _NavDest({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
  });
}

class _NavItem extends StatelessWidget {
  final _NavDest dest;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.dest, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  selected ? dest.selectedIcon : dest.icon,
                  key: ValueKey(selected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dest.label,
                style: AppTextStyles.metaLabel.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
