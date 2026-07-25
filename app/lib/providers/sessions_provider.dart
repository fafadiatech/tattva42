import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/session.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((_) => StorageService());

class SessionsNotifier extends AsyncNotifier<List<Session>> {
  @override
  Future<List<Session>> build() async {
    final storage = ref.read(storageServiceProvider);
    final recorded = await storage.loadSessions();

    // Merge seeded + recorded, dedup by id
    final merged = <String, Session>{};
    for (final s in mockSessions) {
      merged[s.id] = s;
    }
    for (final s in recorded) {
      merged[s.id] = s;
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
