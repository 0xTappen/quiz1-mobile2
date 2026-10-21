import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeminiMarkdownText extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool isDark;

  const GeminiMarkdownText({
    super.key,
    required this.text,
    this.textColor = const Color(0xFFE3E3E3),
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block.isCodeBlock) {
          return _buildCodeBlock(context, block.content, block.language);
        } else {
          return _buildTextBlock(context, block.content);
        }
      }).toList(),
    );
  }

  Widget _buildCodeBlock(
      BuildContext context, String code, String? language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1F20) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333537) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Code header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF282A2C)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (language ?? 'code').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark
                        ? const Color(0xFFC4C7C5)
                        : const Color(0xFF64748B),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kode disalin ke papan klip'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFFC4C7C5)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Salin',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFC4C7C5)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.45,
                  color: isDark
                      ? const Color(0xFFE3E3E3)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(BuildContext context, String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check for header
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            line.substring(4),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.substring(3),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.substring(2),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ));
      } else if (line.trim().startsWith('* ') ||
          line.trim().startsWith('- ') ||
          line.trim().startsWith('• ')) {
        // Bullet list item
        final bulletText = line.trim().substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ' • ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFF8AB4F8)
                      : const Color(0xFF2563EB),
                ),
              ),
              Expanded(
                child: _buildRichText(bulletText),
              ),
            ],
          ),
        ));
      } else {
        // Check for numbered list (e.g. "1. ")
        final numMatch = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line.trim());
        if (numMatch != null) {
          final number = numMatch.group(1)!;
          final itemText = numMatch.group(2)!;
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF8AB4F8)
                        : const Color(0xFF2563EB),
                  ),
                ),
                Expanded(
                  child: _buildRichText(itemText),
                ),
              ],
            ),
          ));
        } else {
          // Regular paragraph
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _buildRichText(line),
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        // Bold
        spans.add(TextSpan(
          text: part,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ));
      } else {
        // Handle inline code `code`
        final codeParts = part.split('`');
        for (int j = 0; j < codeParts.length; j++) {
          final cPart = codeParts[j];
          if (cPart.isEmpty) continue;
          if (j % 2 == 1) {
            spans.add(TextSpan(
              text: cPart,
              style: TextStyle(
                fontFamily: 'monospace',
                backgroundColor: isDark
                    ? const Color(0xFF282A2C)
                    : const Color(0xFFE2E8F0),
                color: isDark
                    ? const Color(0xFFC4C7C5)
                    : const Color(0xFF0F172A),
              ),
            ));
          } else {
            spans.add(TextSpan(
              text: cPart,
              style: TextStyle(
                color: textColor,
              ),
            ));
          }
        }
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14.5,
          height: 1.5,
          color: textColor,
        ),
        children: spans,
      ),
    );
  }

  List<_Block> _parseBlocks(String input) {
    final blocks = <_Block>[];
    final lines = input.split('\n');
    bool inCodeBlock = false;
    String? currentLang;
    final codeBuffer = StringBuffer();
    final textBuffer = StringBuffer();

    for (final line in lines) {
      if (line.trim().startsWith('```')) {
        if (!inCodeBlock) {
          // Entering code block
          if (textBuffer.isNotEmpty) {
            blocks.add(_Block(content: textBuffer.toString().trimRight()));
            textBuffer.clear();
          }
          inCodeBlock = true;
          currentLang = line.trim().substring(3).trim();
          if (currentLang.isEmpty) currentLang = null;
        } else {
          // Exiting code block
          inCodeBlock = false;
          blocks.add(_Block(
            content: codeBuffer.toString().trimRight(),
            isCodeBlock: true,
            language: currentLang,
          ));
          codeBuffer.clear();
          currentLang = null;
        }
      } else if (inCodeBlock) {
        codeBuffer.writeln(line);
      } else {
        textBuffer.writeln(line);
      }
    }

    if (inCodeBlock && codeBuffer.isNotEmpty) {
      blocks.add(_Block(
        content: codeBuffer.toString().trimRight(),
        isCodeBlock: true,
        language: currentLang,
      ));
    } else if (textBuffer.isNotEmpty) {
      blocks.add(_Block(content: textBuffer.toString().trimRight()));
    }

    return blocks;
  }
}

class _Block {
  final String content;
  final bool isCodeBlock;
  final String? language;

  _Block({
    required this.content,
    this.isCodeBlock = false,
    this.language,
  });
}
