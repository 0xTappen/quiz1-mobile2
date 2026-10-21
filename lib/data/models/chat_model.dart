import 'dart:convert';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isError: map['isError'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source));
}

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Obrolan Baru',
      messages: (map['messages'] as List<dynamic>? ?? [])
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatSession.fromJson(String source) =>
      ChatSession.fromMap(json.decode(source));
}
