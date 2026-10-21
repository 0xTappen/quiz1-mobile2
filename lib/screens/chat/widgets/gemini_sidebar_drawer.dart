import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/chat_model.dart';

class GeminiSidebarDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final VoidCallback onNewChat;
  final ValueChanged<ChatSession> onSelectSession;
  final ValueChanged<String> onDeleteSession;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const GeminiSidebarDrawer({
    super.key,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewChat,
    required this.onSelectSession,
    required this.onDeleteSession,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bg = isDark ? const Color(0xFF1E1F20) : const Color(0xFFF0F4F9);
    final surfaceColor =
        isDark ? const Color(0xFF282A2C) : const Color(0xFFFFFFFF);
    final textCol = isDark ? const Color(0xFFE3E3E3) : const Color(0xFF1E293B);
    final mutedCol = isDark ? const Color(0xFF8E918F) : const Color(0xFF64748B);
    final borderCol =
        isDark ? const Color(0xFF333537) : const Color(0xFFE2E8F0);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Gemini Logo & Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
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
                      const SizedBox(width: 10),
                      Text(
                        'Gemini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textCol,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: mutedCol, size: 20),
                    tooltip: 'Tutup Sidebar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // "+ Obrolan baru" Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onNewChat();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderCol),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: isDark
                              ? const Color(0xFF8AB4F8)
                              : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Obrolan Baru',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Section Title: "Terbaru"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                'Terbaru',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: mutedCol,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Recent Chats List
            Expanded(
              child: sessions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 32,
                              color: mutedCol.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada riwayat obrolan',
                              style: TextStyle(
                                fontSize: 13,
                                color: mutedCol,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sessions.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isSelected = session.id == activeSessionId;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF282A2C)
                                    : const Color(0xFFE2E8F0))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            leading: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF8AB4F8)
                                      : const Color(0xFF2563EB))
                                  : mutedCol,
                            ),
                            title: Text(
                              session.title.isEmpty
                                  ? 'Obrolan Baru'
                                  : session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: textCol,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: mutedCol,
                              ),
                              tooltip: 'Hapus Chat',
                              onPressed: () => onDeleteSession(session.id),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              onSelectSession(session);
                            },
                          ),
                        );
                      },
                    ),
            ),

            Divider(height: 1, color: borderCol),

            // Theme toggle button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                onTap: onToggleTheme,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        size: 18,
                        color: mutedCol,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDark ? 'Mode Terang' : 'Mode Gelap',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Profile Info & Return to Cashly
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: isDark
                        ? const Color(0xFF333537)
                        : const Color(0xFFE2E8F0),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Text(
                            user?.displayName?.isNotEmpty == true
                                ? user!.displayName![0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Pengguna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: mutedCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, color: mutedCol, size: 18),
                    tooltip: 'Kembali ke Cashly',
                    onPressed: () {
                      Navigator.of(context).pop(); // close drawer
                      Navigator.of(context).pop(); // exit chat screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
