import 'package:alheekmahlib_website/core/utils/constants/extensions/convert_number_extension.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../core/services/services_locator.dart';
import '../../../core/utils/helpers/app_router.dart';
import '../../../core/widgets/language_list.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 820;
    final isCompact = width < 520;

    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isCompact ? 12 : 14,
      vertical: isCompact ? 8 : 10,
    );
    final buttonDensity =
        isCompact ? VisualDensity.compact : VisualDensity.standard;
    final buttonTextStyle = textTheme.labelLarge?.copyWith(
      fontFamily: 'cairo',
      fontWeight: FontWeight.w600,
      height: .7,
    );

    final copyrightBadge = Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copyright, size: 14, color: scheme.onSurfaceVariant),
          const Gap(6),
          Text(
            '${'appName'.tr} • ${'1446'.convertNumbers()}',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontFamily: 'cairo',
              height: 1.3,
            ),
          ),
        ],
      ),
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => sl<AppRouter>().onItemTapped(6, context),
          icon: const Icon(Icons.code, size: 16),
          label: Text('developers_title'.tr, style: buttonTextStyle),
          style: ElevatedButton.styleFrom(
            padding: buttonPadding,
            elevation: 0,
            visualDensity: buttonDensity,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            shape: const StadiumBorder(),
            minimumSize: const Size(150, 40),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => sl<AppRouter>().onItemTapped(5, context),
          icon: const Icon(Icons.send_outlined, size: 16),
          label: Text('cta_start_project'.tr, style: buttonTextStyle),
          style: ElevatedButton.styleFrom(
            padding: buttonPadding,
            elevation: 0,
            visualDensity: buttonDensity,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: const StadiumBorder(),
            minimumSize: const Size(150, 40),
          ),
        ),
        const LanguageList(),
      ],
    );

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Gap(isWide ? 10 : 8),
                if (isWide)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      copyrightBadge,
                      actions,
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copyrightBadge,
                      const Gap(10),
                      actions,
                    ],
                  ),
                Gap(isWide ? 10 : 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
