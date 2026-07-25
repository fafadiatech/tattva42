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

  Future<void> updateStatus(String id, ExtractionStatus status) async {
    final current = await future;
    final idx = current.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final updated = [...current];
    updated[idx] = updated[idx].copyWith(status: status);

    final storage = ref.read(storageServiceProvider);
    // persist only non-seeded extractions
    final persisted = updated.where((e) =>
        !mockExtractions.any((m) => m.id == e.id)).toList();
    await storage.saveExtractions(persisted);

    state = AsyncData(updated);
  }
}

final extractionsProvider =
    AsyncNotifierProvider<ExtractionsNotifier, List<Extraction>>(ExtractionsNotifier.new);

final extractionsBySessionProvider =
    Provider.family<List<Extraction>, String>((ref, sessionId) {
  final all = ref.watch(extractionsProvider);
  return all.maybeWhen(
    data: (list) => list.where((e) => e.sessionId == sessionId).toList(),
    orElse: () => [],
  );
});
