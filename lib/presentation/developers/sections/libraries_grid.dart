import 'package:flutter/material.dart';

import '../cards/library/developer_library_card.dart';
import '../models/developer_models.dart';
import '../widgets/state_widgets.dart';

/// A responsive grid widget that displays library items.
///
/// Displays a card container with a responsive grid layout that adapts
/// based on available width:
/// - 3 columns for widths >= 1100
/// - 2 columns for widths >= 700
/// - 1 column for smaller widths
class LibrariesGrid extends StatelessWidget {
  /// Creates a [LibrariesGrid] widget.
  ///
  /// The [items] parameter is required and contains the library items to display.
  const LibrariesGrid({super.key, required this.items, this.openItemId});

  /// The list of library items to display in the grid.
  final List<DeveloperItem> items;
  final String? openItemId;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState();
    }

    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          int crossAxisCount = 1;
          if (w >= 1100) {
            crossAxisCount = 3;
          } else if (w >= 700) {
            crossAxisCount = 2;
          }
          double aspect;
          if (crossAxisCount == 1) {
            aspect = 1.12;
          } else if (crossAxisCount == 2) {
            aspect = 1.25;
          } else {
            aspect = 4 / 3.2;
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspect,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return DeveloperLibraryCard(
                item: item,
                autoOpen: openItemId != null && item.id == openItemId,
              );
            },
          );
        }),
      ),
    );
  }
}
