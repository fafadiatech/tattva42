import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../mock/mock_data.dart';
import '../models/session.dart';
import '../providers/player_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/utterances_provider.dart';
import '../theme/app_text_styles.dart';
import '../widgets/playback_controls.dart';
import '../widgets/utterance_row.dart';

class MomentViewScreen extends ConsumerWidget {
  final String sessionId;
  final String utteranceId;

  const MomentViewScreen({
    super.key,
    required this.sessionId,
    required this.utteranceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionByIdProvider(sessionId));
    final allUtterances = ref.watch(utterancesBySessionProvider(sessionId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (session == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Session not found.')));
    }

    final targetIdx = allUtterances.indexWhere((u) => u.id == utteranceId);
    if (targetIdx < 0) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Moment not found.')));
    }

    // Context: 5 before and 5 after
    final from = (targetIdx - 5).clamp(0, allUtterances.length - 1);
    final to = (targetIdx + 5).clamp(0, allUtterances.length - 1);
    final contextUtterances = allUtterances.sublist(from, to + 1);
    final target = allUtterances[targetIdx];
    final person = mockPeople.where((p) => p.id == target.speakerId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_outlined),
            tooltip: 'Pin',
            onPressed: () => _showSnack(context, 'Pinned'),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _showSnack(context, 'Share coming soon'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Speaker header
          Container(
            color: cs.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (person?.avatarColor ?? cs.primary).withAlpha(40),
                  child: Text(
                    person?.name.isNotEmpty == true ? person!.name[0] : '?',
                    style: AppTextStyles.avatarSmall.copyWith(
                      color: person?.avatarColor ?? cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person?.name ?? target.speakerId,
                        style: tt.titleSmall?.merge(AppTextStyles.sectionHeading)),
                    if (person?.role != null)
                      Text(person!.role!,
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
                const Spacer(),
                Text(
                  _fmt(target.offset),
                  style: tt.labelSmall?.copyWith(
                    color: cs.outline,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          // Utterance list
          Expanded(
            child: ListView.builder(
              itemCount: contextUtterances.length,
              itemBuilder: (_, i) {
                final u = contextUtterances[i];
                return UtteranceRow(
                  utterance: u,
                  isActive: u.id == utteranceId,
                  onTap: session.audioPath != null
                      ? () => ref.read(playerProvider.notifier).seekToOffset(u.offset)
                      : null,
                );
              },
            ),
          ),

          // Playback or disabled placeholder
          if (session.audioPath != null)
            PlaybackControls(audioPath: session.audioPath!)
          else
            _NoAudioBar(session: session),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete moment?'),
        content: const Text('This moment will be removed from the session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _NoAudioBar extends StatelessWidget {
  final Session session;
  const _NoAudioBar({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_off_outlined, size: 18, color: cs.outline),
          const SizedBox(width: 8),
          Text(
            'No audio file — transcript only',
            style: AppTextStyles.statusLabel.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
