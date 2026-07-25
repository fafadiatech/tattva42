import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/extraction.dart';
import '../models/session.dart';
import '../models/utterance.dart';

class StorageService {
  static const String _sessionsFileName = 'sessions.json';
  static const String _utterancesFileName = 'utterances.json';
  static const String _extractionsFileName = 'extractions.json';

  Future<Directory> get _docsDir => getApplicationDocumentsDirectory();

  Future<File> _file(String name) async {
    final dir = await _docsDir;
    return File('${dir.path}/$name');
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  Future<List<Session>> loadSessions() async {
    try {
      final f = await _file(_sessionsFileName);
      if (!f.existsSync()) return [];
      final raw = jsonDecode(await f.readAsString()) as List;
      return raw.map((e) => Session.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<Session> sessions) async {
    final f = await _file(_sessionsFileName);
    await f.writeAsString(jsonEncode(sessions.map((s) => s.toJson()).toList()));
  }

  Future<void> saveSession(Session session) async {
    final existing = await loadSessions();
    final idx = existing.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      existing[idx] = session;
    } else {
      existing.add(session);
    }
    await saveSessions(existing);
  }

  // ---------------------------------------------------------------------------
  // Utterances
  // ---------------------------------------------------------------------------

  Future<List<Utterance>> loadUtterances() async {
    try {
      final f = await _file(_utterancesFileName);
      if (!f.existsSync()) return [];
      final raw = jsonDecode(await f.readAsString()) as List;
      return raw.map((e) => Utterance.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUtterances(List<Utterance> utterances) async {
    final f = await _file(_utterancesFileName);
    await f.writeAsString(jsonEncode(utterances.map((u) => u.toJson()).toList()));
  }

  Future<void> appendUtterances(List<Utterance> newUtterances) async {
    final existing = await loadUtterances();
    existing.addAll(newUtterances);
    await saveUtterances(existing);
  }

  // ---------------------------------------------------------------------------
  // Extractions
  // ---------------------------------------------------------------------------

  Future<List<Extraction>> loadExtractions() async {
    try {
      final f = await _file(_extractionsFileName);
      if (!f.existsSync()) return [];
      final raw = jsonDecode(await f.readAsString()) as List;
      return raw.map((e) => Extraction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExtractions(List<Extraction> extractions) async {
    final f = await _file(_extractionsFileName);
    await f.writeAsString(jsonEncode(extractions.map((e) => e.toJson()).toList()));
  }

  // ---------------------------------------------------------------------------
  // Orphan recovery: scan docs dir for .m4a files not referenced by any session
  // ---------------------------------------------------------------------------

  Future<List<String>> findOrphanedAudioFiles(List<Session> knownSessions) async {
    final dir = await _docsDir;
    final knownPaths = knownSessions
        .where((s) => s.audioPath != null)
        .map((s) => s.audioPath!)
        .toSet();

    final orphans = <String>[];
    final entities = dir.listSync();
    for (final e in entities) {
      if (e is File && e.path.endsWith('.m4a')) {
        if (!knownPaths.contains(e.path)) {
          orphans.add(e.path);
        }
      }
    }
    return orphans;
  }

  Future<String> get audioDirectory async {
    final dir = await _docsDir;
    return dir.path;
  }
}
