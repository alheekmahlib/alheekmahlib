part of '../our_apps.dart';

class _AppCard extends StatelessWidget {
  _AppCard(this.app);

  final OurAppInfo app;
  final appCtrl = AppsInfoController.instance;
  final FloatingMenuAnchoredOverlayController controller =
      FloatingMenuAnchoredOverlayController();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final apps = app;
    return Obx(() => MouseRegion(
          onEnter: (_) => appCtrl.hoveredId.value = apps.id,
          onExit: (_) => appCtrl.hoveredId.value = null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: appCtrl.hoveredId.value == apps.id
                  ? [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 38,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: FloatingMenuAnchoredOverlay(
              controller: controller,
              closeOnScroll: true,
              expandFromAnchor: true,
              panelWidth: 680,
              panelHeight: 610,
              style: FloatingMenuAnchoredOverlayStyle(
                barrierColor: scheme.scrim.withValues(alpha: 0.40),
                barrierBlurSigmaX: 10,
                barrierBlurSigmaY: 10,
                panelBorderRadius: const BorderRadius.all(Radius.circular(16)),
                panelDecoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.92),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                ),
              ),
              panelChild: AppsInfo(
                apps: apps,
                controller: controller,
              ),
              anchorBuilder: (context, toggle) => InkWell(
                  // key: Key('grid_item_$index'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    toggle();
                  },
                  child: _gridCard(apps, scheme, context)),
              child: _gridCard(apps, scheme, context),
            ),
          ),
        ));
  }

  Column _gridCard(OurAppInfo apps, ColorScheme scheme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Banner
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14), topRight: Radius.circular(14)),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              apps.appBanner,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: scheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: scheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported_outlined,
                    color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
        // Title/Logo
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SvgPicture.network(apps.appLogo, width: 22, height: 22),
              ),
              const Gap(10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    apps.appTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              apps.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'cairo',
                fontSize: 13,
                height: 1.35,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
