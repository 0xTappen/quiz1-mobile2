import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/chat_model.dart';

class ChatStorageService {
  static const String _sessionsKey = 'gemini_chat_sessions_v1';
  static const String _activeSessionIdKey = 'gemini_active_session_id_v1';

  static Future<List<ChatSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      return raw.map((jsonStr) => ChatSession.fromJson(jsonStr)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSessions(List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = sessions.map((s) => s.toJson()).toList();
    await prefs.setStringList(_sessionsKey, stringList);
  }

  static Future<String?> getActiveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeSessionIdKey);
  }

  static Future<void> setActiveSessionId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSessionIdKey, id);
  }

  static Future<void> deleteSession(String sessionId) async {
    final sessions = await loadSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await saveSessions(sessions);
  }
}
