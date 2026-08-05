import 'package:flutter/material.dart';

import '../cards/api/developer_api_card.dart';
import '../models/developer_models.dart';
import '../widgets/state_widgets.dart';

/// A responsive grid widget that displays API items.
///
/// Displays a responsive grid layout that adapts based on available width:
/// - 3 columns for widths >= 1000
/// - 2 columns for widths >= 650
/// - 1 column for smaller widths
class ApiGrid extends StatelessWidget {
  /// Creates an [ApiGrid] widget.
  ///
  /// The [apis] parameter is required and contains the API items to display.
  const ApiGrid({super.key, required this.apis, this.openItemId});

  /// The list of API items to display in the grid.
  final List<DeveloperItem> apis;
  final String? openItemId;

  @override
  Widget build(BuildContext context) {
    if (apis.isEmpty) {
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

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: apis.length,
        itemBuilder: (context, index) {
          final api = apis[index];
          return DeveloperApiCard(
            api: api,
            autoOpen: openItemId != null && api.id == openItemId,
          );
        },
      );
    });
  }
}
