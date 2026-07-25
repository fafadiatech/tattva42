import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../theme/app_text_styles.dart';

class PlaybackControls extends ConsumerWidget {
  final String audioPath;
  const PlaybackControls({super.key, required this.audioPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ps = ref.watch(playerProvider);
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(playerProvider.notifier);

    // Auto-load on first build
    if (!ps.isLoaded || ps.loadedPath != audioPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.load(audioPath);
      });
    }

    final duration = ps.duration ?? Duration.zero;
    final position = ps.position;
    final max = duration.inMilliseconds.toDouble();
    final cur = position.inMilliseconds.toDouble().clamp(0, max);

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubber
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: cs.primary,
              inactiveTrackColor: cs.surfaceContainerHighest,
              thumbColor: cs.primary,
            ),
            child: Slider(
              value: cur.toDouble(),
              max: max > 0 ? max : 1,
              onChanged: max > 0
                  ? (v) => notifier.seekTo(Duration(milliseconds: v.round()))
                  : null,
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(position),
                  style: AppTextStyles.tabularTime.copyWith(color: cs.outline),
                ),
                Text(
                  _fmt(duration),
                  style: AppTextStyles.tabularTime.copyWith(color: cs.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () => notifier.seekTo(
                    position - const Duration(seconds: 10) < Duration.zero
                        ? Duration.zero
                        : position - const Duration(seconds: 10)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: ps.isBuffering
                    ? null
                    : () => ps.isPlaying ? notifier.pause() : notifier.play(),
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: ps.isBuffering
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(ps.isPlaying ? Icons.pause : Icons.play_arrow, size: 26),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final target = position + const Duration(seconds: 10);
                  notifier.seekTo(target > duration ? duration : target);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
