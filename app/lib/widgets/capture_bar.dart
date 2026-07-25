import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/recorder_provider.dart';
import '../theme/app_text_styles.dart';
import 'live_capture_sheet.dart';

class CaptureBar extends ConsumerWidget {
  const CaptureBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorder = ref.watch(recorderProvider);
    final cs = Theme.of(context).colorScheme;

    final isActive = recorder.status != RecordingStatus.idle &&
        recorder.status != RecordingStatus.stopped;

    return Material(
      color: isActive ? cs.primaryContainer : cs.surfaceContainerLow,
      child: InkWell(
        onTap: () => _handleTap(context, ref, recorder),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatusDot(status: recorder.status),
                const SizedBox(width: 10),
                Expanded(child: _StatusLabel(status: recorder.status, elapsed: recorder.elapsed)),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  _ElapsedTimer(elapsed: recorder.elapsed),
                ],
                const SizedBox(width: 8),
                Icon(
                  isActive ? Icons.mic : Icons.mic_none_outlined,
                  size: 20,
                  color: isActive ? cs.primary : cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(
      BuildContext context, WidgetRef ref, RecorderState recorder) {
    if (recorder.status == RecordingStatus.idle ||
        recorder.status == RecordingStatus.stopped) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const LiveCaptureSheet(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const LiveCaptureSheet(),
      );
    }
  }
}

class _StatusDot extends StatelessWidget {
  final RecordingStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color dotColor;
    bool pulse = false;
    switch (status) {
      case RecordingStatus.recording:
        dotColor = cs.error;
        pulse = true;
      case RecordingStatus.paused:
        dotColor = cs.tertiary;
      case RecordingStatus.processing:
        dotColor = cs.secondary;
      default:
        dotColor = cs.outline;
    }
    if (pulse) {
      return _PulsingDot(color: dotColor);
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
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
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
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
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final RecordingStatus status;
  final Duration elapsed;
  const _StatusLabel({required this.status, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String label;
    switch (status) {
      case RecordingStatus.recording:
        label = 'Recording';
      case RecordingStatus.paused:
        label = 'Paused';
      case RecordingStatus.processing:
        label = 'Processing…';
      case RecordingStatus.stopped:
        label = 'Tap to start a new recording';
      case RecordingStatus.idle:
        label = 'Tap to start a new recording';
    }
    return Text(
      label,
      style: AppTextStyles.statusLabel.copyWith(
        color: status == RecordingStatus.idle || status == RecordingStatus.stopped
            ? cs.onSurfaceVariant
            : cs.onPrimaryContainer,
      ),
    );
  }
}

class _ElapsedTimer extends StatelessWidget {
  final Duration elapsed;
  const _ElapsedTimer({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text(
      '$m:$s',
      style: AppTextStyles.captureTimer.copyWith(
        color: cs.onPrimaryContainer,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
