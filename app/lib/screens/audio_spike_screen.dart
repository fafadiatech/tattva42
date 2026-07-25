import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/player_provider.dart';
import '../providers/recorder_provider.dart';
import '../widgets/amplitude_waveform.dart';

class AudioSpikeScreen extends ConsumerStatefulWidget {
  const AudioSpikeScreen({super.key});

  @override
  ConsumerState<AudioSpikeScreen> createState() => _AudioSpikeScreenState();
}

class _AudioSpikeScreenState extends ConsumerState<AudioSpikeScreen> {
  String? _recordedPath;
  String _log = 'Ready. Tap Record to start the spike test.\n';

  void _addLog(String msg) {
    setState(() => _log += '${DateTime.now().toIso8601String().substring(11, 19)} $msg\n');
  }

  Future<void> _startRecording() async {
    final notifier = ref.read(recorderProvider.notifier);
    final granted = await notifier.requestPermission();
    if (!granted) {
      _addLog('Permission denied — cannot record.');
      return;
    }
    await notifier.startRecording();
    _addLog('Recording started.');
  }

  Future<void> _stopRecording() async {
    final notifier = ref.read(recorderProvider.notifier);
    _addLog('Stopping recording…');
    final path = await notifier.stopRecording();
    _addLog('Stopped. Path: $path');
    setState(() => _recordedPath = path);
    notifier.reset();
  }

  Future<void> _playRecording() async {
    if (_recordedPath == null) {
      _addLog('No recording to play.');
      return;
    }
    _addLog('Loading player…');
    await ref.read(playerProvider.notifier).load(_recordedPath!);
    await ref.read(playerProvider.notifier).play();
    _addLog('Playback started.');
  }

  Future<void> _stopPlayback() async {
    await ref.read(playerProvider.notifier).pause();
    _addLog('Playback paused.');
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(recorderProvider);
    final player = ref.watch(playerProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio spike test'),
        leading: BackButton(onPressed: () => context.go('/you')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recorder: ${recorder.status.name}',
                        style: tt.labelMedium),
                    Text('Player: ${player.isPlaying ? "playing" : "idle"}',
                        style: tt.labelMedium),
                    if (_recordedPath != null)
                      Text('File: $_recordedPath',
                          style: tt.labelSmall?.copyWith(color: cs.outline),
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Waveform
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: AmplitudeWaveform(samples: recorder.amplitudeSamples),
              ),
            ),

            const SizedBox(height: 12),

            // Elapsed
            if (recorder.status == RecordingStatus.recording)
              Center(
                child: Text(
                  _fmtElapsed(recorder.elapsed),
                  style: tt.displaySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),

            // Playback scrubber
            if (player.isLoaded) ...[
              const SizedBox(height: 8),
              Slider(
                value: player.position.inMilliseconds.toDouble().clamp(
                    0.0, (player.duration?.inMilliseconds ?? 1).toDouble()),
                max: (player.duration?.inMilliseconds ?? 1).toDouble(),
                onChanged: (v) => ref
                    .read(playerProvider.notifier)
                    .seekTo(Duration(milliseconds: v.round())),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmtElapsed(player.position), style: tt.labelSmall),
                    Text(_fmtElapsed(player.duration ?? Duration.zero), style: tt.labelSmall),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Buttons
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: recorder.status == RecordingStatus.idle ? _startRecording : null,
                  icon: const Icon(Icons.fiber_manual_record, size: 16),
                  label: const Text('Record'),
                ),
                FilledButton.icon(
                  onPressed: recorder.status == RecordingStatus.recording ? _stopRecording : null,
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Stop'),
                ),
                OutlinedButton.icon(
                  onPressed: _recordedPath != null && !player.isPlaying ? _playRecording : null,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Play'),
                ),
                OutlinedButton.icon(
                  onPressed: player.isPlaying ? _stopPlayback : null,
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text('Pause'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Log
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_log, style: tt.labelSmall?.copyWith(fontFamily: 'monospace')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
