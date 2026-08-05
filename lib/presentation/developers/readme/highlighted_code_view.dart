import 'package:flutter/material.dart';

/// A widget that displays code with syntax highlighting.
///
/// This widget provides basic syntax highlighting for code blocks,
/// with colors matching the GitHub dark theme.
class HighlightedCodeView extends StatelessWidget {
  /// Creates a [HighlightedCodeView] widget.
  const HighlightedCodeView({super.key, required this.code});

  /// The code string to display with syntax highlighting.
  final String code;

  // Syntax highlighting colors matching GitHub dark theme
  static const Map<String, Color> _keywordColors = {
    'import': Color(0xFFFF7B72),
    'export': Color(0xFFFF7B72),
    'from': Color(0xFFFF7B72),
    'class': Color(0xFFFF7B72),
    'extends': Color(0xFFFF7B72),
    'implements': Color(0xFFFF7B72),
    'void': Color(0xFFFF7B72),
    'String': Color(0xFFFF7B72),
    'int': Color(0xFFFF7B72),
    'double': Color(0xFFFF7B72),
    'bool': Color(0xFFFF7B72),
    'var': Color(0xFFFF7B72),
    'final': Color(0xFFFF7B72),
    'const': Color(0xFFFF7B72),
    'static': Color(0xFFFF7B72),
    'async': Color(0xFFFF7B72),
    'await': Color(0xFFFF7B72),
    'return': Color(0xFFFF7B72),
    'if': Color(0xFFFF7B72),
    'else': Color(0xFFFF7B72),
    'for': Color(0xFFFF7B72),
    'while': Color(0xFFFF7B72),
    'switch': Color(0xFFFF7B72),
    'case': Color(0xFFFF7B72),
    'break': Color(0xFFFF7B72),
    'continue': Color(0xFFFF7B72),
    'try': Color(0xFFFF7B72),
    'catch': Color(0xFFFF7B72),
    'throw': Color(0xFFFF7B72),
    'new': Color(0xFFFF7B72),
    'this': Color(0xFFFF7B72),
    'super': Color(0xFFFF7B72),
    'null': Color(0xFF79C0FF),
    'true': Color(0xFF79C0FF),
    'false': Color(0xFF79C0FF),
  };

  static const Color _stringColor = Color(0xFFA5D6FF);
  static const Color _commentColor = Color(0xFF8B949E);
  static const Color _numberColor = Color(0xFF79C0FF);
  static const Color _defaultColor = Colors.white;

  List<TextSpan> _highlightCode(String code) {
    final spans = <TextSpan>[];
    final lines = code.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineSpans = _highlightLine(line);
      spans.addAll(lineSpans);

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  List<TextSpan> _highlightLine(String line) {
    final spans = <TextSpan>[];
    var remaining = line;

    while (remaining.isNotEmpty) {
      // Check for comments
      if (remaining.startsWith('//')) {
        spans.add(TextSpan(
          text: remaining,
          style: const TextStyle(color: _commentColor),
        ));
        break;
      }

      // Check for strings (single or double quotes)
      if (remaining.startsWith('"') || remaining.startsWith("'")) {
        final quote = remaining[0];
        final endIndex = _findStringEnd(remaining, quote);
        if (endIndex > 0) {
          spans.add(TextSpan(
            text: remaining.substring(0, endIndex + 1),
            style: const TextStyle(color: _stringColor),
          ));
          remaining = remaining.substring(endIndex + 1);
          continue;
        }
      }

      // Check for keywords and identifiers
      final match = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)').firstMatch(remaining);
      if (match != null) {
        final word = match.group(1)!;
        final color = _keywordColors[word] ?? _defaultColor;
        spans.add(TextSpan(
          text: word,
          style: TextStyle(color: color),
        ));
        remaining = remaining.substring(word.length);
        continue;
      }

      // Check for numbers
      final numberMatch = RegExp(r'^(\d+\.?\d*)').firstMatch(remaining);
      if (numberMatch != null) {
        final number = numberMatch.group(1)!;
        spans.add(TextSpan(
          text: number,
          style: const TextStyle(color: _numberColor),
        ));
        remaining = remaining.substring(number.length);
        continue;
      }

      // Default: add single character
      spans.add(TextSpan(
        text: remaining[0],
        style: const TextStyle(color: _defaultColor),
      ));
      remaining = remaining.substring(1);
    }

    return spans;
  }

  int _findStringEnd(String text, String quote) {
    for (var i = 1; i < text.length; i++) {
      if (text[i] == quote && text[i - 1] != '\\') {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: _highlightCode(code),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
