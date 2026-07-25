enum CaptureMode { ambient, meeting, dictation }

enum SyncState { synced, pending, local }

class Session {
  final String id;
  final String title;
  final String summary;
  final DateTime startedAt;
  final Duration duration;
  final CaptureMode mode;
  final String? location;
  final List<String> participantIds;
  final SyncState syncState;
  final bool isPrivate;
  final String? audioPath;
  final bool isSeeded;

  const Session({
    required this.id,
    required this.title,
    required this.summary,
    required this.startedAt,
    required this.duration,
    required this.mode,
    this.location,
    required this.participantIds,
    required this.syncState,
    required this.isPrivate,
    this.audioPath,
    required this.isSeeded,
  });

  Session copyWith({
    String? id,
    String? title,
    String? summary,
    DateTime? startedAt,
    Duration? duration,
    CaptureMode? mode,
    String? location,
    List<String>? participantIds,
    SyncState? syncState,
    bool? isPrivate,
    String? audioPath,
    bool? isSeeded,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      startedAt: startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
      mode: mode ?? this.mode,
      location: location ?? this.location,
      participantIds: participantIds ?? this.participantIds,
      syncState: syncState ?? this.syncState,
      isPrivate: isPrivate ?? this.isPrivate,
      audioPath: audioPath ?? this.audioPath,
      isSeeded: isSeeded ?? this.isSeeded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'startedAt': startedAt.toIso8601String(),
      'duration': duration.inMilliseconds,
      'mode': mode.name,
      'location': location,
      'participantIds': participantIds,
      'syncState': syncState.name,
      'isPrivate': isPrivate,
      'audioPath': audioPath,
      'isSeeded': isSeeded,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      duration: Duration(milliseconds: json['duration'] as int),
      mode: CaptureMode.values.byName(json['mode'] as String),
      location: json['location'] as String?,
      participantIds: List<String>.from(json['participantIds'] as List),
      syncState: SyncState.values.byName(json['syncState'] as String),
      isPrivate: json['isPrivate'] as bool,
      audioPath: json['audioPath'] as String?,
      isSeeded: json['isSeeded'] as bool? ?? false,
    );
  }
}
