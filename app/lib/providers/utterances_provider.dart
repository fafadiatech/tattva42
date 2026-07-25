import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/utterance.dart';
import 'sessions_provider.dart';

class UtterancesNotifier extends AsyncNotifier<List<Utterance>> {
  @override
  Future<List<Utterance>> build() async {
    final storage = ref.read(storageServiceProvider);
    final recorded = await storage.loadUtterances();
    final merged = <Utterance>[...mockUtterances, ...recorded];
    merged.sort((a, b) => a.offset.compareTo(b.offset));
    return merged;
  }

  Future<void> addUtterances(List<Utterance> utterances) async {
    final storage = ref.read(storageServiceProvider);
    await storage.appendUtterances(utterances);
    ref.invalidateSelf();
  }
}

final utterancesProvider =
    AsyncNotifierProvider<UtterancesNotifier, List<Utterance>>(UtterancesNotifier.new);

/// Per-session utterances provider that fetches from the API when available,
/// falling back to the local+mock corpus for seeded/offline sessions.
final utterancesBySessionProvider =
    FutureProvider.family<List<Utterance>, String>((ref, sessionId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final apiUtterances = await api.getUtterancesForSession(sessionId);
    if (apiUtterances.isNotEmpty) return apiUtterances;
  } catch (_) {
    // API unavailable or session not on backend — fall through to local data.
  }

  // Fallback: filter from the local+mock corpus.
  final all = await ref.watch(utterancesProvider.future);
  return all
      .where((u) => u.sessionId == sessionId)
      .toList()
    ..sort((a, b) => a.offset.compareTo(b.offset));
});
