import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/services/services_locator.dart';
import '../../controllers/developers_controller.dart';
import '../../models/developer_models.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/action_button.dart';

/// A generic card widget for displaying developer items.
///
/// Displays a simple card with title, description, and an optional action button.
class GenericCard extends StatelessWidget {
  /// Creates a [GenericCard].
  const GenericCard({super.key, required this.item});

  /// The developer item to display.
  final DeveloperItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedText(item.title),
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Gap(8),
          Text(
            localizedText(item.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          if (item.url.isNotEmpty)
            ActionButton(
              icon: Icons.open_in_new,
              label: 'developers_open'.tr,
              onTap: () => sl<DevelopersController>().openUrl(item.url),
            ),
        ],
      ),
    );
  }
}
