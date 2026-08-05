import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/services/services_locator.dart';
import '../../../core/utils/helpers/app_router.dart';

/// A header block widget for the developers screen.
///
/// Displays the title, a badge, an optional update timestamp,
/// and a button to open the developers dashboard.
class HeaderBlock extends StatelessWidget {
  /// Creates a [HeaderBlock].
  ///
  /// The [scheme] parameter is required. The [updatedAt] parameter is optional.
  const HeaderBlock({
    super.key,
    required this.scheme,
    this.updatedAt,
  });

  /// The color scheme to use for styling.
  final ColorScheme scheme;

  /// The optional timestamp of when the content was last updated.
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
              child: Text(
                'developers_title'.tr,
                style: TextStyle(color: scheme.primary, fontFamily: 'cairo'),
              ),
            ),
            const Gap(10),
            Text(
              'developers_title'.tr,
              style: const TextStyle(
                fontFamily: 'cairo',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => sl<AppRouter>().onItemTapped(7, context),
              icon: const Icon(Icons.dashboard_outlined, size: 18),
              label: Text(
                'developers_open_dashboard'.tr,
                style: const TextStyle(fontFamily: 'cairo'),
              ),
            ),
          ],
        ),
        if (updatedAt != null && updatedAt!.isNotEmpty) ...[
          const Gap(8),
          Text(
            '${'developers_updated'.tr} $updatedAt',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontFamily: 'cairo',
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
