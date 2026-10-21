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

  /// AI Financial Advisor: Menganalisa transaksi keuangan bulanan pengguna
  static Future<String> analyzeFinances({
    required String userName,
    required double monthlyIncome,
    required double monthlyExpense,
    required double remainingBudget,
    required Map<String, double> categoryBreakdown,
    required List<String> recentTxSummaries,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(
        'Kamu adalah Penasihat Keuangan Pribadi (Financial Advisor) profesional, empatik, dan solutif.');
    buffer.writeln(
        'Analisis data keuangan bulan ini untuk pengguna bernama "$userName" berikut:');
    buffer.writeln('- Total Pemasukan: Rp ${monthlyIncome.toStringAsFixed(0)}');
    buffer.writeln('- Total Pengeluaran: Rp ${monthlyExpense.toStringAsFixed(0)}');
    final sisaSaldo = monthlyIncome - monthlyExpense;
    buffer.writeln('- Sisa Arus Kas / Saldo Bersih: Rp ${sisaSaldo.toStringAsFixed(0)}');
    buffer.writeln('- Sisa Budget Anggaran: Rp ${remainingBudget.toStringAsFixed(0)}');

    if (categoryBreakdown.isNotEmpty) {
      buffer.writeln('\nRincian Pengeluaran per Kategori:');
      categoryBreakdown.forEach((category, amount) {
        final pct = monthlyExpense > 0
            ? (amount / monthlyExpense * 100).toStringAsFixed(1)
            : '0';
        buffer.writeln('  * $category: Rp ${amount.toStringAsFixed(0)} ($pct%)');
      });
    }

    if (recentTxSummaries.isNotEmpty) {
      buffer.writeln('\nTransaksi Terakhir:');
      for (final tx in recentTxSummaries.take(5)) {
        buffer.writeln('  - $tx');
      }
    }

    buffer.writeln('''
Format analisis kamu dengan rapi menggunakan Markdown dan emoji:
1. 📊 **Status & Evaluasi Kesehatan Keuangan** (Beri rating: Sehat / Waspada / Perlu Perhatian beserta alasan singkat).
2. ⚠️ **Area Pengeluaran Terbesar & Potensi Boros** (Sebutkan kategori paling dominan dan apakah wajar).
3. 💡 **3 Langkah Aksi & Tips Hemat Praktis** (Saran konkret yang bisa langsung diterapkan).
4. 🔮 **Proyeksi Sisa Saldo & Rekomendasi Budgeting 50/30/20** (Saran pembagian Kebutuhan 50%, Keinginan 30%, Tabungan/Investasi 20%).

Tulis dengan bahasa Indonesia yang ramah, memotivasi, dan mudah dicerna. Maksimal 3-4 paragraf yang padat.''');

    return sendMessage(
      conversationHistory: [],
      prompt: buffer.toString(),
    );
  }
}
