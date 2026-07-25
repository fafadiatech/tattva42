enum ExtractionKind { commitment, decision, question, figure }

enum ExtractionStatus { pending, accepted, dismissed }

class Extraction {
  final String id;
  final String sessionId;
  final String utteranceId;
  final String text;
  final ExtractionKind kind;
  final String? owedBy;
  final String? dueHint;
  final ExtractionStatus status;

  const Extraction({
    required this.id,
    required this.sessionId,
    required this.utteranceId,
    required this.text,
    required this.kind,
    this.owedBy,
    this.dueHint,
    required this.status,
  });

  Extraction copyWith({
    String? id,
    String? sessionId,
    String? utteranceId,
    String? text,
    ExtractionKind? kind,
    String? owedBy,
    String? dueHint,
    ExtractionStatus? status,
  }) {
    return Extraction(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      utteranceId: utteranceId ?? this.utteranceId,
      text: text ?? this.text,
      kind: kind ?? this.kind,
      owedBy: owedBy ?? this.owedBy,
      dueHint: dueHint ?? this.dueHint,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'utteranceId': utteranceId,
      'text': text,
      'kind': kind.name,
      'owedBy': owedBy,
      'dueHint': dueHint,
      'status': status.name,
    };
  }

  factory Extraction.fromJson(Map<String, dynamic> json) {
    return Extraction(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      utteranceId: json['utteranceId'] as String,
      text: json['text'] as String,
      kind: ExtractionKind.values.byName(json['kind'] as String),
      owedBy: json['owedBy'] as String?,
      dueHint: json['dueHint'] as String?,
      status: ExtractionStatus.values.byName(json['status'] as String),
    );
  }

  /// Construct an [Extraction] from the Django REST Framework API response.
  /// The API uses snake_case and UUID FK fields (`session`, `utterance`, `owed_by`).
  factory Extraction.fromApi(Map<String, dynamic> json) {
    final dueHint = json['due_hint'] as String?;
    return Extraction(
      id: json['id'] as String,
      sessionId: json['session'] as String,
      utteranceId: json['utterance'] as String,
      text: json['text'] as String,
      kind: ExtractionKind.values.byName(json['kind'] as String),
      owedBy: json['owed_by'] as String?,
      dueHint: (dueHint != null && dueHint.isNotEmpty) ? dueHint : null,
      status: ExtractionStatus.values.byName(json['status'] as String),
    );
  }
}
