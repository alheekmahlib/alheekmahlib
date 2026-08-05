import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../models/developer_models.dart';
import '../../utils/localization_helper.dart';

/// The body content of an API card.
///
/// Displays the API title, version badge, description, and base URL.
class ApiCardBody extends StatelessWidget {
  /// Creates an [ApiCardBody].
  const ApiCardBody({super.key, required this.api});

  /// The API item to display.
  final DeveloperItem api;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, color: scheme.primary),
              const Gap(8),
              Expanded(
                child: Text(
                  localizedText(api.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (api.version.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    api.version,
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 11,
                      color: scheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(8),
          Text(
            localizedText(api.description),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'cairo',
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Text(
            api.baseUrl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'cairo',
              fontSize: 11,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
