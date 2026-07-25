import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../providers/recorder_provider.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';
import 'amplitude_waveform.dart';

class LiveCaptureSheet extends ConsumerStatefulWidget {
  const LiveCaptureSheet({super.key});

  @override
  ConsumerState<LiveCaptureSheet> createState() => _LiveCaptureSheetState();
}

class _LiveCaptureSheetState extends ConsumerState<LiveCaptureSheet> {
  final List<Duration> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  Future<void> _startIfNeeded() async {
    final status = ref.read(recorderProvider).status;
    if (status == RecordingStatus.idle || status == RecordingStatus.stopped) {
      await ref.read(recorderProvider.notifier).startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(recorderProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    _labelFor(recorder.status),
                    style: tt.titleMedium?.merge(AppTextStyles.sheetTitle),
                  ),
                ),
                _StatusIndicator(status: recorder.status),
              ],
            ),
            const SizedBox(height: 16),

            // Waveform
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AmplitudeWaveform(
                  samples: recorder.amplitudeSamples,
                  color: recorder.status == RecordingStatus.paused
                      ? cs.tertiary
                      : cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Elapsed
            Text(
              _formatDuration(recorder.elapsed),
              style: tt.displaySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            if (_bookmarks.isNotEmpty)
              Text(
                '${_bookmarks.length} bookmark${_bookmarks.length == 1 ? '' : 's'} marked',
                style: tt.bodySmall?.copyWith(color: cs.secondary),
              ),
            const SizedBox(height: 20),

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Discard
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Discard',
                  color: cs.error,
                  onTap: () => _confirmDiscard(context),
                ),

                // Mark moment
                _ActionButton(
                  icon: Icons.bookmark_add_outlined,
                  label: 'Mark moment',
                  color: cs.secondary,
                  onTap: recorder.status == RecordingStatus.recording
                      ? _markMoment
                      : null,
                ),

                // Pause / resume
                _ActionButton(
                  icon: recorder.status == RecordingStatus.paused
                      ? Icons.play_arrow
                      : Icons.pause,
                  label: recorder.status == RecordingStatus.paused ? 'Resume' : 'Pause',
                  color: cs.tertiary,
                  onTap: recorder.status == RecordingStatus.recording
                      ? _pause
                      : recorder.status == RecordingStatus.paused
                          ? _resume
                          : null,
                ),

                // Stop
                _ActionButton(
                  icon: Icons.stop_circle_outlined,
                  label: 'Stop',
                  color: cs.primary,
                  onTap: recorder.status == RecordingStatus.processing
                      ? null
                      : _stop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markMoment() {
    final elapsed = ref.read(recorderProvider).elapsed;
    setState(() => _bookmarks.add(elapsed));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moment marked at ${_formatDuration(elapsed)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pause() async {
    await ref.read(recorderProvider.notifier).pauseRecording();
  }

  Future<void> _resume() async {
    await ref.read(recorderProvider.notifier).resumeRecording();
  }

  Future<void> _stop() async {
    final notifier = ref.read(recorderProvider.notifier);
    final elapsed = ref.read(recorderProvider).elapsed;
    final path = await notifier.stopRecording();

    if (path != null && mounted) {
      final session = Session(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Recording ${_shortTimestamp()}',
        summary: 'Recorded on ${_fullTimestamp()}',
        startedAt: DateTime.now().subtract(elapsed),
        duration: elapsed,
        mode: CaptureMode.ambient,
        location: null,
        participantIds: [],
        syncState: SyncState.local,
        isPrivate: false,
        audioPath: path,
        isSeeded: false,
      );
      await ref.read(sessionsProvider.notifier).addSession(session);
    }

    notifier.reset();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard recording?'),
        content: const Text('The audio will be deleted and cannot be recovered.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final notifier = ref.read(recorderProvider.notifier);
      await notifier.stopRecording();
      notifier.reset();
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    }
  }

  String _labelFor(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return 'Recording in progress';
      case RecordingStatus.paused:
        return 'Recording paused';
      case RecordingStatus.processing:
        return 'Processing…';
      default:
        return 'Starting recording…';
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _shortTimestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _fullTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusIndicator extends StatelessWidget {
  final RecordingStatus status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String text;
    Color bg;
    switch (status) {
      case RecordingStatus.recording:
        text = 'Live';
        bg = cs.error;
      case RecordingStatus.paused:
        text = 'Paused';
        bg = cs.tertiary;
      case RecordingStatus.processing:
        text = 'Processing';
        bg = cs.secondary;
      default:
        text = 'Starting';
        bg = cs.outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.metaLabel.copyWith(
          color: cs.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.modeChip.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

