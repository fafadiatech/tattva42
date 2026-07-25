class Utterance {
  final String id;
  final String sessionId;
  final String speakerId;
  final String text;
  final Duration offset;
  final Duration? end;
  final double? confidence;

  const Utterance({
    required this.id,
    required this.sessionId,
    required this.speakerId,
    required this.text,
    required this.offset,
    this.end,
    this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'speakerId': speakerId,
      'text': text,
      'offset': offset.inMilliseconds,
      'end': end?.inMilliseconds,
      'confidence': confidence,
    };
  }

  factory Utterance.fromJson(Map<String, dynamic> json) {
    return Utterance(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      speakerId: json['speakerId'] as String,
      text: json['text'] as String,
      offset: Duration(milliseconds: json['offset'] as int),
      end: json['end'] != null ? Duration(milliseconds: json['end'] as int) : null,
      confidence: json['confidence'] as double?,
    );
  }

  /// Construct an [Utterance] from the Django REST Framework API response.
  /// The API uses snake_case and `session`/`speaker` as UUID FK fields.
  factory Utterance.fromApi(Map<String, dynamic> json) {
    return Utterance(
      id: json['id'] as String,
      sessionId: json['session'] as String,
      speakerId: json['speaker'] as String? ?? 'unknown',
      text: json['text'] as String,
      offset: Duration(milliseconds: json['offset_ms'] as int),
      end: json['end_ms'] != null
          ? Duration(milliseconds: json['end_ms'] as int)
          : null,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}
