import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/player_service.dart';

class PlayerState {
  final bool isPlaying;
  final bool isLoaded;
  final Duration position;
  final Duration? duration;
  final String? loadedPath;
  final bool isBuffering;

  const PlayerState({
    required this.isPlaying,
    required this.isLoaded,
    required this.position,
    this.duration,
    this.loadedPath,
    required this.isBuffering,
  });

  static const initial = PlayerState(
    isPlaying: false,
    isLoaded: false,
    position: Duration.zero,
    isBuffering: false,
  );

  PlayerState copyWith({
    bool? isPlaying,
    bool? isLoaded,
    Duration? position,
    Duration? duration,
    String? loadedPath,
    bool? isBuffering,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoaded: isLoaded ?? this.isLoaded,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loadedPath: loadedPath ?? this.loadedPath,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerService _service;

  PlayerNotifier(this._service) : super(PlayerState.initial) {
    _service.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _service.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
    _service.stateStream.listen((ps) {
      final buffering =
          ps.processingState == ProcessingState.loading ||
          ps.processingState == ProcessingState.buffering;
      state = state.copyWith(
        isPlaying: ps.playing,
        isBuffering: buffering,
      );
    });
  }

  Future<void> load(String path) async {
    state = state.copyWith(isLoaded: false, loadedPath: path);
    await _service.load(path);
    state = state.copyWith(isLoaded: true, loadedPath: path);
  }

  Future<void> play() async => _service.play();
  Future<void> pause() async => _service.pause();
  Future<void> seekTo(Duration position) async => _service.seekTo(position);

  Future<void> seekToOffset(Duration offset) async {
    await _service.seekTo(offset);
    await _service.play();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

final playerServiceProvider = Provider<PlayerService>((ref) {
  final service = PlayerServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final service = ref.watch(playerServiceProvider);
  return PlayerNotifier(service);
});
