import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/constants/extensions/dimensions.dart';
import '../../controllers/developers_controller.dart';
import '../../models/developer_models.dart';
import '../../readme/readme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/action_button.dart';

/// A panel displaying detailed information about a library.
///
/// Shows the library title, description, banner image, screenshots,
/// action buttons, and README content in a scrollable view with a close button.
class LibraryDetailsPanel extends StatelessWidget {
  /// Creates a [LibraryDetailsPanel].
  const LibraryDetailsPanel({
    super.key,
    required this.item,
    required this.onClose,
  });

  /// The library item to display details for.
  final DeveloperItem item;

  /// Callback to close the panel.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ctrl = sl<DevelopersController>();
    final scheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // X button at the top (not scrollable)
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Gap(8.0),
                    Center(
                      child: Text(
                        localizedText(item.title),
                        style: TextStyle(
                          color: context.textDarkColor,
                          fontSize: 18,
                          fontFamily: 'cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 16,
                      thickness: 2,
                      endIndent: 16,
                      indent: 16,
                    ),
                    if (item.bannerUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.bannerUrl),
                      ),
                    if (localizedText(item.description).isNotEmpty) ...[
                      const Gap(10),
                      Text(
                        localizedText(item.description),
                        style: TextStyle(
                          fontFamily: 'cairo',
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (item.screenshots != null &&
                        item.screenshots!.isNotEmpty) ...[
                      const Gap(12),
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: item.screenshots!.length,
                          separatorBuilder: (_, __) => const Gap(8),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.screenshots![index],
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.docsUrl.isNotEmpty)
                          ActionButton(
                            icon: Icons.article_outlined,
                            label: 'developers_docs'.tr,
                            onTap: () => ctrl.openUrl(item.docsUrl),
                          ),
                        if (item.githubUrl.isNotEmpty)
                          ActionButton(
                            icon: Icons.code,
                            label: 'developers_github'.tr,
                            onTap: () => ctrl.openUrl(item.githubUrl),
                          ),
                        if (item.downloadUrl.isNotEmpty)
                          ActionButton(
                            icon: Icons.download_outlined,
                            label: 'developers_download'.tr,
                            onTap: () => ctrl.openUrl(item.downloadUrl),
                          ),
                      ],
                    ),
                    if (item.readmeUrl.isNotEmpty) ...[
                      const Gap(16),
                      ReadmeBlock(url: item.readmeUrl),
                    ],
                    const Gap(32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
