import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/chat_model.dart';
import '../../services/chat_storage_service.dart';
import '../../services/gemini_service.dart';
import 'widgets/gemini_markdown_text.dart';
import 'widgets/gemini_sidebar_drawer.dart';

class GeminiChatScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onNavigateHome;

  const GeminiChatScreen({
    super.key,
    this.isEmbedded = false,
    this.onNavigateHome,
  });

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  late bool _isDark;
  bool _hasInputText = false;

  @override
  void initState() {
    super.initState();
    _isDark = false; // Chatbot bertema putih (light mode) sesuai request
    _textController.addListener(_onTextChanged);
    _loadHistoryAndSession();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasInputText) {
      setState(() => _hasInputText = hasText);
    }
  }

  Future<void> _loadHistoryAndSession() async {
    final loaded = await ChatStorageService.loadSessions();
    final activeId = await ChatStorageService.getActiveSessionId();

    setState(() {
      _sessions = loaded;
      if (activeId != null) {
        final found = _sessions.where((s) => s.id == activeId);
        if (found.isNotEmpty) {
          _currentSession = found.first;
        }
      }
      if (_currentSession == null) {
        _createNewSession(saveOld: false);
      }
    });

    _scrollToBottom();
  }

  void _createNewSession({bool saveOld = true}) {
    if (saveOld && _currentSession != null && _currentSession!.messages.isNotEmpty) {
      _saveCurrentSession();
    }

    final newSession = ChatSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      title: 'Obrolan Baru',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentSession = newSession;
      if (!_sessions.any((s) => s.id == newSession.id)) {
        _sessions.insert(0, newSession);
      }
    });

    ChatStorageService.setActiveSessionId(newSession.id);
    ChatStorageService.saveSessions(_sessions);
  }

  void _switchSession(ChatSession session) {
    setState(() {
      _currentSession = session;
    });
    ChatStorageService.setActiveSessionId(session.id);
    _scrollToBottom();
  }

  Future<void> _deleteSession(String sessionId) async {
    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSession?.id == sessionId) {
        if (_sessions.isNotEmpty) {
          _currentSession = _sessions.first;
          ChatStorageService.setActiveSessionId(_currentSession!.id);
        } else {
          _createNewSession(saveOld: false);
        }
      }
    });
    await ChatStorageService.deleteSession(sessionId);
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;
    _currentSession!.updatedAt = DateTime.now();

    final idx = _sessions.indexWhere((s) => s.id == _currentSession!.id);
    if (idx != -1) {
      _sessions[idx] = _currentSession!;
    } else {
      _sessions.insert(0, _currentSession!);
    }
    await ChatStorageService.saveSessions(_sessions);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final query = _textController.text.trim();
    if (query.isEmpty || _isLoading) return;

    _textController.clear();
    setState(() => _hasInputText = false);

    if (_currentSession == null) {
      _createNewSession(saveOld: false);
    }

    // If first message in this session, update title based on query
    if (_currentSession!.messages.isEmpty) {
      final cleanTitle = query.length > 30 ? '${query.substring(0, 30)}...' : query;
      _currentSession!.title = cleanTitle;
    }

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentSession!.messages.add(userMsg);
      _isLoading = true;
    });

    _scrollToBottom();
    await _saveCurrentSession();

    try {
      final reply = await GeminiService.sendMessage(
        conversationHistory: _currentSession!.messages,
        prompt: query,
      );

      final modelMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _currentSession!.messages.add(modelMsg);
        _isLoading = false;
      });

      _scrollToBottom();
      await _saveCurrentSession();
    } catch (e) {
      final errorMsg = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Terjadi kendala saat menghubungi Gemini: ${e.toString().replaceAll('Exception: ', '')}',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      setState(() {
        _currentSession!.messages.add(errorMsg);
        _isLoading = false;
      });

      _scrollToBottom();
      await _saveCurrentSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = (currentUser?.displayName?.isNotEmpty == true)
        ? currentUser!.displayName!.split(' ').first
        : 'Sobat FinTrack';

    final bgColor =
        _isDark ? const Color(0xFF131314) : const Color(0xFFF0F4F9);
    final cardColor =
        _isDark ? const Color(0xFF1E1F20) : const Color(0xFFFFFFFF);
    final textColor =
        _isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1E293B);
    final mutedColor =
        _isDark ? const Color(0xFF8E918F) : const Color(0xFF64748B);
    final borderColor =
        _isDark ? const Color(0xFF333537) : const Color(0xFFE2E8F0);

    final messages = _currentSession?.messages ?? [];
    final isChatEmpty = messages.isEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: GeminiSidebarDrawer(
        sessions: _sessions,
        activeSessionId: _currentSession?.id,
        onNewChat: () => _createNewSession(saveOld: true),
        onSelectSession: _switchSession,
        onDeleteSession: _deleteSession,
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: textColor),
            tooltip: 'Buka Menu Sidebar',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF9B72CF),
                  Color(0xFFD96570),
                ],
              ).createShader(bounds),
              child: const Text(
                'Gemini',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _isDark
                    ? const Color(0xFF282A2C)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '2.5 Flash',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: mutedColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note_rounded, color: textColor, size: 24),
            tooltip: 'Obrolan Baru',
            onPressed: () => _createNewSession(saveOld: true),
          ),
          IconButton(
            icon: Icon(
              widget.isEmbedded ? Icons.home_outlined : Icons.close_rounded,
              color: mutedColor,
              size: 22,
            ),
            tooltip: widget.isEmbedded ? 'Ke Beranda' : 'Tutup Chat',
            onPressed: () {
              if (widget.isEmbedded) {
                widget.onNavigateHome?.call();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat body (Empty state or message list)
            Expanded(
              child: isChatEmpty
                  ? _buildEmptyState(userName, textColor, mutedColor)
                  : _buildMessageList(messages, textColor, mutedColor, cardColor),
            ),

            // Bottom Input Section (Gemini Pill Style)
            _buildInputArea(bgColor, cardColor, borderColor, textColor, mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      String userName, Color textColor, Color mutedColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gemini Sparkle Logo
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4285F4),
                    Color(0xFF9B72CF),
                    Color(0xFFD96570),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 24),

            // Gradient Greeting: "Halo, [Nama]"
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF9B72CF),
                  Color(0xFFD96570),
                ],
              ).createShader(bounds),
              child: Text(
                'Halo, $userName',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Ada yang bisa saya bantu hari ini?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: mutedColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tanyakan apa saja tentang tips keuangan, analisis anggaran, atau pengetahuan umum.',
              style: TextStyle(
                fontSize: 14,
                color: mutedColor.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages, Color textColor,
      Color mutedColor, Color cardColor) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isLoading) {
          return _buildThinkingIndicator(mutedColor);
        }

        final msg = messages[index];
        if (msg.isUser) {
          return _buildUserMessage(msg, textColor);
        } else {
          return _buildModelMessage(msg, textColor, mutedColor);
        }
      },
    );
  }

  Widget _buildUserMessage(ChatMessage msg, Color textColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF282A2C) : const Color(0xFFE2E8F0),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: SelectableText(
          msg.text,
          style: TextStyle(
            fontSize: 14.5,
            height: 1.45,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildModelMessage(
      ChatMessage msg, Color textColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gemini Sparkle Avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF9B72CF),
                  Color(0xFFD96570),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),

          // Message content and actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeminiMarkdownText(
                  text: msg.text,
                  textColor: msg.isError ? Colors.redAccent : textColor,
                  isDark: _isDark,
                ),
                const SizedBox(height: 8),

                // Gemini Action Toolbar (Copy, Thumbs Up, Thumbs Down)
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: msg.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Teks respons disalin'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terima kasih atas tanggapan Anda!'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tanggapan Anda telah dicatat.'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.thumb_down_alt_outlined,
                          size: 16,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF9B72CF),
                  Color(0xFFD96570),
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          Row(
            children: [
              Text(
                'Gemini sedang berpikir...',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: mutedColor,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(mutedColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(Color bgColor, Color cardColor, Color borderColor,
      Color textColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gemini Input Box (Floating Pill)
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: textColor,
                    ),
                    cursorColor: const Color(0xFF4285F4),
                    decoration: InputDecoration(
                      hintText: 'Tanya Gemini...',
                      hintStyle: TextStyle(
                        fontSize: 14.5,
                        color: mutedColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => _onTextChanged(),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasInputText
                          ? const Color(0xFF4285F4)
                          : (_isDark
                              ? const Color(0xFF282A2C)
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_upward_rounded,
                        size: 20,
                        color: _hasInputText
                            ? Colors.white
                            : mutedColor,
                      ),
                      onPressed: () => _handleSend(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Disclaimer Footer like Gemini Web
          Text(
            'Gemini dapat menampilkan info yang tidak akurat, jadi periksa kembali responsnya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: mutedColor.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
