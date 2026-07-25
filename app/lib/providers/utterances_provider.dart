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

final utterancesBySessionProvider =
    Provider.family<List<Utterance>, String>((ref, sessionId) {
  final all = ref.watch(utterancesProvider);
  return all.maybeWhen(
    data: (list) =>
        list.where((u) => u.sessionId == sessionId).toList()
          ..sort((a, b) => a.offset.compareTo(b.offset)),
    orElse: () => [],
  );
});
