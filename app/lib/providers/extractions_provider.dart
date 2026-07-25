import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/extraction.dart';
import 'sessions_provider.dart';

class ExtractionsNotifier extends AsyncNotifier<List<Extraction>> {
  @override
  Future<List<Extraction>> build() async {
    final storage = ref.read(storageServiceProvider);
    final recorded = await storage.loadExtractions();
    return [...mockExtractions, ...recorded];
  }

  /// Update the status of an extraction locally and, when possible, on the API.
  Future<void> updateStatus(String id, ExtractionStatus status) async {
    // Try to persist the change to the backend first.
    try {
      final api = ref.read(apiServiceProvider);
      if (status == ExtractionStatus.accepted) {
        await api.acceptExtraction(id);
      } else if (status == ExtractionStatus.dismissed) {
        await api.dismissExtraction(id);
      }
    } catch (_) {
      // API unavailable or extraction not found on backend — continue with
      // local update only so the UI remains responsive.
    }

    final current = await future;
    final idx = current.indexWhere((e) => e.id == id);
    if (idx < 0) return; // extraction is API-only (not in local list); API call above is enough.

    final updated = [...current];
    updated[idx] = updated[idx].copyWith(status: status);

    final storage = ref.read(storageServiceProvider);
    // Only persist non-seeded extractions to local storage.
    final persisted = updated
        .where((e) => !mockExtractions.any((m) => m.id == e.id))
        .toList();
    await storage.saveExtractions(persisted);

    state = AsyncData(updated);
  }
}

final extractionsProvider =
    AsyncNotifierProvider<ExtractionsNotifier, List<Extraction>>(
        ExtractionsNotifier.new);

/// Per-session extractions provider that fetches from the API when available,
/// falling back to the local+mock corpus for seeded/offline sessions.
final extractionsBySessionProvider =
    FutureProvider.family<List<Extraction>, String>((ref, sessionId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final apiExtractions = await api.getExtractionsForSession(sessionId);
    if (apiExtractions.isNotEmpty) return apiExtractions;
  } catch (_) {
    // API unavailable or session not on backend — fall through to local data.
  }

  // Fallback: filter from the local+mock corpus.
  final all = await ref.watch(extractionsProvider.future);
  return all.where((e) => e.sessionId == sessionId).toList();
});
