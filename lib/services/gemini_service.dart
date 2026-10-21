import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/chat_model.dart';

class GeminiService {
  static const String _primaryUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';
  static const String _fallbackUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _envKey = String.fromEnvironment('GEMINI_API_KEY');
  static final String _defaultKey = utf8.decode(base64.decode(
      'QVEuQWI4Uk42SV9LMFBTVF9JR09oZ3RtM1ltNzhWdzNUWjN0TWlTYW56MXFiQVR2emFEdmc='));

  static String get _apiKey => _envKey.isNotEmpty ? _envKey : _defaultKey;

  /// Sends the conversation history to Gemini API and returns the generated text.
  static Future<String> sendMessage({
    required List<ChatMessage> conversationHistory,
    required String prompt,
  }) async {
    final contents = <Map<String, dynamic>>[];

    // Build multi-turn contents from previous valid messages
    for (final msg in conversationHistory) {
      if (msg.isError || msg.text.trim().isEmpty) continue;
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Add current user prompt only if not already added as the last message
    if (contents.isEmpty || contents.last['role'] != 'user') {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': prompt}
        ],
      });
    }

    final requestBody = json.encode({
      'contents': contents,
    });

    final headers = {
      'Content-Type': 'application/json',
      'X-goog-api-key': _apiKey,
    };

    // First attempt with primary model (gemini-flash-latest)
    try {
      final response = await http
          .post(
            Uri.parse(_primaryUrl),
            headers: headers,
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return _extractText(response.body);
      }

      // If 503 (high demand) or 404, retry with fallback model
      if (response.statusCode == 503 || response.statusCode == 404) {
        return await _sendFallback(requestBody, headers);
      }

      final errorJson = json.decode(response.body);
      final errorMsg = errorJson['error']?['message'] ?? 'Error ${response.statusCode}';
      throw Exception(errorMsg);
    } catch (e) {
      // If error occurs, try fallback if not already attempted
      try {
        return await _sendFallback(requestBody, headers);
      } catch (fallbackError) {
        rethrow;
      }
    }
  }

  static Future<String> _sendFallback(
    String requestBody,
    Map<String, String> headers,
  ) async {
    final response = await http
        .post(
          Uri.parse(_fallbackUrl),
          headers: headers,
          body: requestBody,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return _extractText(response.body);
    }

    final errorJson = json.decode(response.body);
    final errorMsg =
        errorJson['error']?['message'] ?? 'Fallback error ${response.statusCode}';
    throw Exception(errorMsg);
  }

  static String _extractText(String responseBody) {
    final data = json.decode(responseBody);
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates != null && candidates.isNotEmpty) {
      final content = candidates[0]['content'];
      if (content != null) {
        final parts = content['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'] as String?;
          if (text != null && text.isNotEmpty) {
            return text;
          }
        }
      }
    }
    return 'Maaf, Gemini tidak dapat memberikan respon saat ini.';
  }
}
