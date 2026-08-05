import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../models/developer_models.dart';
import '../utils/localization_helper.dart';
import 'api_grid.dart';
import 'downloads_grid.dart';
import 'generic_grid.dart';
import 'libraries_grid.dart';

/// A widget that displays a section with a title, description, and appropriate grid.
///
/// This widget renders a section block that includes:
/// - A section title
/// - An optional description
/// - The appropriate grid widget based on the section type:
///   - [LibrariesGrid] for 'libraries' type
///   - [ApiGrid] for 'api' type
///   - [GenericGrid] for all other types
class SectionBlock extends StatelessWidget {
  /// Creates a [SectionBlock] widget.
  ///
  /// The [section] parameter is required and contains the section data to display.
  const SectionBlock({
    super.key,
    required this.section,
    this.openType,
    this.openItemId,
  });

  /// The section data containing title, description, type, and items.
  final DeveloperSection section;
  final DevelopersOpenType? openType;
  final String? openItemId;

  @override
  Widget build(BuildContext context) {
    final title = localizedText(section.title);
    final description = localizedText(section.description);

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          if (description.isNotEmpty) ...[
            const Gap(6),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'cairo',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const Gap(12),
          if (section.type == 'libraries')
            LibrariesGrid(
              items: section.items.where((i) => i.enabled).toList(),
              openItemId:
                  openType == DevelopersOpenType.libraries ? openItemId : null,
            )
          else if (section.type == 'api')
            ApiGrid(
              apis: section.items.where((i) => i.enabled).toList(),
              openItemId:
                  openType == DevelopersOpenType.api ? openItemId : null,
            )
          else if (section.type == 'downloads')
            DownloadsGrid(
              items: section.items.where((i) => i.enabled).toList(),
            )
          else
            GenericGrid(items: section.items.where((i) => i.enabled).toList()),
        ],
      ),
    );
  }
}
