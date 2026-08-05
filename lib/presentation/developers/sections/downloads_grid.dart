import 'package:flutter/material.dart';

import '../cards/downloads/download_card.dart';
import '../models/developer_models.dart';
import '../widgets/state_widgets.dart';

/// A responsive grid widget that displays download items.
class DownloadsGrid extends StatelessWidget {
  const DownloadsGrid({super.key, required this.items});

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
          childAspectRatio: 2,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return DownloadCard(item: items[index]);
        },
      );
    });
  }
}
