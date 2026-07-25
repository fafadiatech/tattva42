import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/session.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((_) => StorageService());

final apiServiceProvider = Provider<ApiService>((_) => ApiService());

class SessionsNotifier extends AsyncNotifier<List<Session>> {
  @override
  Future<List<Session>> build() async {
    final storage = ref.read(storageServiceProvider);
    final api = ref.read(apiServiceProvider);

    // Load local recordings (user-recorded sessions with real audio files).
    final local = await storage.loadSessions();

    // Try the API. On failure, fall back to mock + local.
    List<Session> apiSessions = [];
    try {
      apiSessions = await api.getSessions();
    } catch (_) {
      // API unreachable — use mock data as the seeded baseline.
      apiSessions = mockSessions;
    }

    // Merge strategy:
    // 1. API sessions are the source of truth for seeded / server-side data.
    // 2. Local sessions that have an audioPath override API sessions with the
    //    same id (they are the same recording, but with a local file attached).
    // 3. Local sessions not found in API are appended (unsynced recordings).
    final merged = <String, Session>{};
    for (final s in apiSessions) {
      merged[s.id] = s;
    }
    for (final s in local) {
      if (s.audioPath != null) {
        // Prefer local version when audio is available locally.
        merged[s.id] = s;
      } else {
        merged.putIfAbsent(s.id, () => s);
      }
    }

    final sorted = merged.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sorted;
  }

  Future<void> addSession(Session session) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveSession(session);
    ref.invalidateSelf();
  }

  Future<void> updateSession(Session session) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveSession(session);
    ref.invalidateSelf();
  }
}

final sessionsProvider =
    AsyncNotifierProvider<SessionsNotifier, List<Session>>(SessionsNotifier.new);

final sessionByIdProvider = Provider.family<Session?, String>((ref, id) {
  final sessions = ref.watch(sessionsProvider);
  return sessions.maybeWhen(
    data: (list) {
      try {
        return list.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
