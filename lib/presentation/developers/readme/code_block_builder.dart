import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:markdown/markdown.dart' as md show Element;

import 'highlighted_code_view.dart';

/// A [MarkdownElementBuilder] for rendering code blocks with syntax highlighting
/// and a copy button.
///
/// This builder creates a styled container with a header containing a copy button
/// and the highlighted code content below.
class CodeBlockBuilder extends MarkdownElementBuilder {
  /// Creates a [CodeBlockBuilder] with the required callbacks and state.
  CodeBlockBuilder({
    required this.onCopy,
    required this.copiedStates,
  });

  /// Callback function invoked when the copy button is pressed.
  /// The [code] parameter contains the code to copy, and [key] is a unique
  /// identifier for tracking the copy state.
  final Function(String code, String key) onCopy;

  /// A map tracking the copy state for each code block.
  /// The key is the code block's hash code, and the value indicates
  /// whether the code has been copied.
  final Map<String, bool> copiedStates;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final code = element.textContent;
    final key = code.hashCode.toString();
    final isCopied = copiedStates[key] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => onCopy(code, key),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCopied
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCopied
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCopied ? Icons.check : Icons.copy,
                          size: 14,
                          color: isCopied ? Colors.green : Colors.white70,
                        ),
                        const Gap(6),
                        Text(
                          isCopied ? 'Copied!' : 'Copy',
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontSize: 12,
                            color: isCopied ? Colors.green : Colors.white70,
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
            padding: const EdgeInsets.all(16),
            child: HighlightedCodeView(code: code),
          ),
        ],
      ),
    );
  }
}
