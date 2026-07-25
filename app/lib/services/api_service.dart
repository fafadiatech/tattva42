import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/citation.dart';
import '../models/extraction.dart';
import '../models/mock_answer.dart';
import '../models/session.dart';
import '../models/utterance.dart';

/// Base URL for the Django backend.
/// - iOS Simulator / macOS: 127.0.0.1:8000
/// - Android Emulator:      10.0.2.2:8000
/// - Real device on LAN:    change to your machine's LAN IP, e.g. 192.168.1.42:8000
String get _baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api/v1';
  }
  return 'http://127.0.0.1:8000/api/v1';
}

class ApiService {
  final _client = http.Client();

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  Future<List<Session>> getSessions() async {
    final uri = Uri.parse('$_baseUrl/sessions/?page_size=100&ordering=-started_at');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('getSessions failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((e) => Session.fromApi(e as Map<String, dynamic>)).toList();
  }

  Future<Session> createSession(Session session) async {
    final uri = Uri.parse('$_baseUrl/sessions/');
    final body = jsonEncode({
      'title': session.title,
      'summary': session.summary,
      'started_at': session.startedAt.toUtc().toIso8601String(),
      'duration_seconds': session.duration.inSeconds,
      'mode': session.mode.name,
      'location': session.location ?? '',
      'sync_state': 'synced',
      'is_private': session.isPrivate,
      'is_seeded': false,
    });
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 201) {
      throw Exception('createSession failed: ${response.statusCode} ${response.body}');
    }
    return Session.fromApi(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> uploadAudio(String sessionId, String localPath) async {
    final uri = Uri.parse('$_baseUrl/sessions/$sessionId/upload-audio/');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('audio', localPath));
    final streamed = await _client.send(request);
    if (streamed.statusCode != 200) {
      throw Exception('uploadAudio failed: ${streamed.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // Utterances
  // ---------------------------------------------------------------------------

  Future<List<Utterance>> getUtterancesForSession(String sessionId) async {
    final uri = Uri.parse('$_baseUrl/sessions/$sessionId/utterances/?page_size=500');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('getUtterances failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((e) => Utterance.fromApi(e as Map<String, dynamic>)).toList();
  }

  Future<Utterance> createUtterance(Utterance utterance) async {
    final uri = Uri.parse('$_baseUrl/utterances/');
    final body = jsonEncode({
      'session': utterance.sessionId,
      'text': utterance.text,
      'offset_ms': utterance.offset.inMilliseconds,
      'end_ms': utterance.end?.inMilliseconds,
      'confidence': utterance.confidence,
    });
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 201) {
      throw Exception('createUtterance failed: ${response.statusCode}');
    }
    return Utterance.fromApi(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------------------
  // Extractions
  // ---------------------------------------------------------------------------

  Future<List<Extraction>> getExtractionsForSession(String sessionId) async {
    final uri = Uri.parse('$_baseUrl/sessions/$sessionId/extractions/?page_size=100');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('getExtractions failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map((e) => Extraction.fromApi(e as Map<String, dynamic>)).toList();
  }

  Future<void> acceptExtraction(String id) async {
    final uri = Uri.parse('$_baseUrl/extractions/$id/accept/');
    final response = await _client.patch(uri);
    if (response.statusCode != 200) {
      throw Exception('acceptExtraction failed: ${response.statusCode}');
    }
  }

  Future<void> dismissExtraction(String id) async {
    final uri = Uri.parse('$_baseUrl/extractions/$id/dismiss/');
    final response = await _client.patch(uri);
    if (response.statusCode != 200) {
      throw Exception('dismissExtraction failed: ${response.statusCode}');
    }
  }

  // ---------------------------------------------------------------------------
  // Ask
  // ---------------------------------------------------------------------------

  Future<MockAnswer> ask(String query) async {
    final uri = Uri.parse('$_baseUrl/ask/');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );
    if (response.statusCode != 200) {
      throw Exception('ask failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final citations = (data['citations'] as List).map((c) {
      return Citation(
        sessionId: (c['session_id'] as String),
        utteranceId: (c['utterance_id'] as String),
      );
    }).toList();
    return MockAnswer(
      answer: data['answer'] as String,
      citations: citations,
    );
  }

  void dispose() => _client.close();
}
