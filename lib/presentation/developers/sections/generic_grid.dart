import 'package:flutter/material.dart';

import '../cards/generic/generic_card.dart';
import '../models/developer_models.dart';
import '../widgets/state_widgets.dart';

/// A responsive grid widget that displays generic items.
///
/// Displays a responsive grid layout that adapts based on available width:
/// - 3 columns for widths >= 1000
/// - 2 columns for widths >= 650
/// - 1 column for smaller widths
class GenericGrid extends StatelessWidget {
  /// Creates a [GenericGrid] widget.
  ///
  /// The [items] parameter is required and contains the generic items to display.
  const GenericGrid({super.key, required this.items});

  /// The list of generic items to display in the grid.
  final List<DeveloperItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState();
    }

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      int crossAxisCount = 1;
      if (w >= 1000) {
        crossAxisCount = 3;
      } else if (w >= 650) {
        crossAxisCount = 2;
      }

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GenericCard(item: items[index]);
        },
      );
    });
  }
}
