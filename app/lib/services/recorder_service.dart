import 'dart:async';

import 'package:record/record.dart';

abstract class RecorderService {
  Stream<double> get amplitudeStream;
  Future<void> start(String filePath);
  Future<String?> stop();
  Future<void> pause();
  Future<void> resume();
  bool get isRecording;
  bool get isPaused;
  void dispose();
}

class RecorderServiceImpl implements RecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  Timer? _amplitudeTimer;
  String? _currentPath;
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<void> start(String filePath) async {
    _currentPath = filePath;

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      numChannels: 1,
      bitRate: 64000,
    );

    await _recorder.start(config, path: filePath);
    _isRecording = true;
    _isPaused = false;
    _startAmplitudePolling();
  }

  @override
  Future<String?> stop() async {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    final path = await _recorder.stop();
    _isRecording = false;
    _isPaused = false;
    return path ?? _currentPath;
  }

  @override
  Future<void> pause() async {
    await _recorder.pause();
    _isPaused = true;
    _amplitudeTimer?.cancel();
    _amplitudeController.add(0.0);
  }

  @override
  Future<void> resume() async {
    await _recorder.resume();
    _isPaused = false;
    _startAmplitudePolling();
  }

  void _startAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      if (!_isRecording || _isPaused) return;
      try {
        final amp = await _recorder.getAmplitude();
        // amp.current is in dBFS (negative). Normalise to 0–1.
        const minDb = -60.0;
        final db = amp.current.clamp(minDb, 0.0);
        final normalised = (db - minDb) / (-minDb);
        _amplitudeController.add(normalised.clamp(0.0, 1.0));
      } catch (_) {
        _amplitudeController.add(0.0);
      }
    });
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _amplitudeController.close();
    _recorder.dispose();
  }
}
