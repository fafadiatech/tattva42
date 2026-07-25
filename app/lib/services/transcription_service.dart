import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/utterance.dart';

abstract class TranscriptionService {
  Future<bool> initialize();
  Future<void> startListening({
    required void Function(Utterance utterance) onUtterance,
    required String sessionId,
    required String speakerId,
  });
  Future<void> stopListening();
  bool get isAvailable;
  bool get isListening;
}

class SpeechToTextTranscriptionService implements TranscriptionService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _listening = false;
  void Function(Utterance)? _onUtterance;
  String _sessionId = '';
  String _speakerId = '';
  int _utteranceIndex = 0;
  DateTime? _sessionStart;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;

  @override
  Future<bool> initialize() async {
    _available = await _speech.initialize(
      onError: (e) => _listening = false,
    );
    return _available;
  }

  @override
  Future<void> startListening({
    required void Function(Utterance utterance) onUtterance,
    required String sessionId,
    required String speakerId,
  }) async {
    if (!_available) return;
    _onUtterance = onUtterance;
    _sessionId = sessionId;
    _speakerId = speakerId;
    _utteranceIndex = 0;
    _sessionStart = DateTime.now();
    _listening = true;
    _listenOnce();
  }

  void _listenOnce() {
    if (!_listening) return;
    _speech.listen(
      onResult: _handleResult,
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  void _handleResult(SpeechRecognitionResult result) {
    if (!result.finalResult) return;
    if (result.recognizedWords.isEmpty) {
      if (_listening) _listenOnce();
      return;
    }

    final elapsed = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    final utterance = Utterance(
      id: '${_sessionId}_u${_utteranceIndex++}',
      sessionId: _sessionId,
      speakerId: _speakerId,
      text: result.recognizedWords,
      offset: elapsed,
      end: null,
      confidence: result.confidence > 0 ? result.confidence : null,
    );
    _onUtterance?.call(utterance);

    if (_listening) _listenOnce();
  }

  @override
  Future<void> stopListening() async {
    _listening = false;
    await _speech.stop();
  }
}
