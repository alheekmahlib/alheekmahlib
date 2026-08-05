import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/services/services_locator.dart';
import '../../controllers/developers_controller.dart';
import '../../models/developer_models.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/action_button.dart';

/// Card for download items with title, description, and a download action.
class DownloadCard extends StatelessWidget {
  const DownloadCard({super.key, required this.item});

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
          if (item.downloadUrl.isNotEmpty)
            Center(
              child: ActionButton(
                icon: Icons.download,
                label: 'developers_download'.tr,
                minimumSize: const Size(double.infinity, 40),
                onTap: () =>
                    sl<DevelopersController>().openUrl(item.downloadUrl),
              ),
            ),
        ],
      ),
    );
  }
}
