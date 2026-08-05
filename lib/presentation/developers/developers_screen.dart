import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../core/services/services_locator.dart';
import 'controllers/developers_controller.dart';
import 'models/developer_models.dart';
import 'sections/sections.dart';
import 'widgets/widgets.dart';

class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({
    super.key,
    this.openType,
    this.openItemId,
  });

  final DevelopersOpenType? openType;
  final String? openItemId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GetBuilder<DevelopersController>(
      init: sl<DevelopersController>(),
      builder: (ctrl) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderBlock(scheme: scheme, updatedAt: ctrl.content?.updatedAt),
              const Gap(16),
              if (ctrl.isLoading)
                const DevelopersLoading()
              else if (ctrl.errorMessage != null)
                ErrorState(message: ctrl.errorMessage!)
              else if (ctrl.content == null || ctrl.content!.sections.isEmpty)
                const EmptyState()
              else
                ...ctrl.content!.sections
                    .where((section) => section.enabled)
                    .map((section) => SectionBlock(
                          section: section,
                          openType: openType,
                          openItemId: openItemId,
                        )),
            ],
          ),
        );
      },
    );
  }
}
