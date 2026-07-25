import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/recorder_service.dart';

enum RecordingStatus { idle, recording, paused, processing, stopped }

class RecorderState {
  final RecordingStatus status;
  final String? filePath;
  final Duration elapsed;
  final List<double> amplitudeSamples;

  const RecorderState({
    required this.status,
    this.filePath,
    required this.elapsed,
    required this.amplitudeSamples,
  });

  RecorderState copyWith({
    RecordingStatus? status,
    String? filePath,
    Duration? elapsed,
    List<double>? amplitudeSamples,
  }) {
    return RecorderState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      elapsed: elapsed ?? this.elapsed,
      amplitudeSamples: amplitudeSamples ?? this.amplitudeSamples,
    );
  }

  static const initial = RecorderState(
    status: RecordingStatus.idle,
    elapsed: Duration.zero,
    amplitudeSamples: [],
  );
}

class RecorderNotifier extends StateNotifier<RecorderState> {
  final RecorderService _service;
  DateTime? _startTime;
  DateTime? _pauseStart;
  Duration _pausedTotal = Duration.zero;

  RecorderNotifier(this._service) : super(RecorderState.initial) {
    _service.amplitudeStream.listen(_onAmplitude);
  }

  void _onAmplitude(double value) {
    if (state.status != RecordingStatus.recording) return;
    final elapsed = _computeElapsed();
    const maxSamples = 80;
    final samples = [...state.amplitudeSamples, value];
    final trimmed =
        samples.length > maxSamples ? samples.sublist(samples.length - maxSamples) : samples;
    state = state.copyWith(elapsed: elapsed, amplitudeSamples: trimmed);
  }

  Duration _computeElapsed() {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!) - _pausedTotal;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    final granted = await requestPermission();
    if (!granted) return;

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/recording_$ts.m4a';

    _startTime = DateTime.now();
    _pausedTotal = Duration.zero;

    await _service.start(path);
    state = RecorderState(
      status: RecordingStatus.recording,
      filePath: path,
      elapsed: Duration.zero,
      amplitudeSamples: const [],
    );
  }

  Future<void> pauseRecording() async {
    if (state.status != RecordingStatus.recording) return;
    _pauseStart = DateTime.now();
    await _service.pause();
    state = state.copyWith(status: RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    if (state.status != RecordingStatus.paused) return;
    if (_pauseStart != null) {
      _pausedTotal += DateTime.now().difference(_pauseStart!);
      _pauseStart = null;
    }
    await _service.resume();
    state = state.copyWith(status: RecordingStatus.recording);
  }

  Future<String?> stopRecording() async {
    if (state.status == RecordingStatus.idle) return null;
    state = state.copyWith(status: RecordingStatus.processing);
    final path = await _service.stop();
    state = state.copyWith(status: RecordingStatus.stopped, filePath: path);
    return path;
  }

  void reset() {
    _startTime = null;
    _pauseStart = null;
    _pausedTotal = Duration.zero;
    state = RecorderState.initial;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final recorderServiceProvider = Provider<RecorderService>((ref) {
  final service = RecorderServiceImpl();
  ref.onDispose(service.dispose);
  return service;
});

final recorderProvider =
    StateNotifierProvider<RecorderNotifier, RecorderState>((ref) {
  final service = ref.watch(recorderServiceProvider);
  return RecorderNotifier(service);
});
