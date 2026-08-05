import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'code_block_builder.dart';

/// A widget that fetches and displays a README markdown file from a URL.
///
/// This widget fetches the README content via HTTP and renders it as
/// formatted markdown with custom styling and syntax-highlighted code blocks.
class ReadmeBlock extends StatefulWidget {
  /// Creates a [ReadmeBlock] widget.
  const ReadmeBlock({super.key, required this.url});

  /// The URL of the README file to fetch and display.
  final String url;

  @override
  State<ReadmeBlock> createState() => ReadmeBlockState();
}

/// The state for [ReadmeBlock].
///
/// Manages the fetching of README content and tracks the copy states
/// for code blocks within the markdown.
class ReadmeBlockState extends State<ReadmeBlock> {
  final Map<String, bool> _copiedStates = {};
  late Future<http.Response> _readmeFuture;

  @override
  void initState() {
    super.initState();
    _readmeFuture = Future.delayed(const Duration(seconds: 1), () {
      return http.get(Uri.parse(widget.url));
    });
  }

  /// Copies the provided code to the clipboard and updates the copy state.
  ///
  /// The [code] parameter is the text to copy, and [key] is a unique
  /// identifier for tracking which code block was copied.
  void _copyToClipboard(String code, String key) async {
    await Clipboard.setData(ClipboardData(text: code));
    setState(() {
      _copiedStates[key] = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedStates[key] = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'developers_readme'.tr,
          style: const TextStyle(
            fontFamily: 'cairo',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const Gap(8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: FutureBuilder<http.Response>(
            future: _readmeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (!snapshot.hasData || snapshot.data?.statusCode != 200) {
                return Text(
                  'developers_readme_error'.tr,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    color: scheme.error,
                    fontSize: 12,
                  ),
                );
              }
              final body = snapshot.data?.body ?? '';
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Markdown(
                  data: body,
                  shrinkWrap: true,
                  selectable: true,
                  physics: const NeverScrollableScrollPhysics(),
                  builders: {
                    'pre': CodeBlockBuilder(
                      onCopy: _copyToClipboard,
                      copiedStates: _copiedStates,
                    ),
                  },
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                    h1: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    h2: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    h3: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    h4: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    h5: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    h6: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    code: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: scheme.onSurface,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                    codeblockPadding: const EdgeInsets.all(16),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    blockquote: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      border: Border(
                        left: BorderSide(
                          color: scheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    listBullet: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                    a: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 14,
                      color: scheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
