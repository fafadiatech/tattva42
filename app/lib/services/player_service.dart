import 'dart:async';

import 'package:just_audio/just_audio.dart';

export 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;

abstract class PlayerService {
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;
  Stream<PlayerState> get stateStream;
  Future<void> load(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> dispose();
  Duration get currentPosition;
  Duration? get currentDuration;
  bool get isPlaying;
}

class PlayerServiceImpl implements PlayerService {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<PlayerState> get stateStream => _player.playerStateStream;

  @override
  Duration get currentPosition => _player.position;

  @override
  Duration? get currentDuration => _player.duration;

  @override
  bool get isPlaying => _player.playing;

  @override
  Future<void> load(String path) async {
    await _player.setFilePath(path);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
