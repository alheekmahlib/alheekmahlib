import 'package:floating_menu_expendable/floating.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/helpers/app_router.dart';
import '../../controllers/api_details_controller.dart';
import '../../models/developer_models.dart';
import 'api_card_body.dart';
import 'api_details_panel.dart';

/// A card widget for displaying API items with expandable details.
///
/// Uses [FloatingMenuAnchoredOverlay] to show a panel with detailed
/// API information when tapped.
class DeveloperApiCard extends StatefulWidget {
  /// Creates a [DeveloperApiCard].
  const DeveloperApiCard({
    super.key,
    required this.api,
    this.autoOpen = false,
  });

  /// The API item to display.
  final DeveloperItem api;
  final bool autoOpen;

  @override
  State<DeveloperApiCard> createState() => _DeveloperApiCardState();
}

class _DeveloperApiCardState extends State<DeveloperApiCard> {
  late final FloatingMenuAnchoredOverlayController _controller =
      FloatingMenuAnchoredOverlayController();
  bool _didAutoOpen = false;
  bool _wasOpen = false;
  int _closeToken = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
    _tryAutoOpen();
  }

  @override
  void didUpdateWidget(covariant DeveloperApiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tryAutoOpen();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final isOpen = _controller.isOpen;
    if (_wasOpen && !isOpen) {
      _maybeReturnToDevelopers();
      _scheduleControllerDispose();
    }
    _wasOpen = isOpen;
  }

  void _scheduleControllerDispose() {
    final token = ++_closeToken;
    Future.delayed(const Duration(milliseconds: 240), () {
      if (!mounted || _controller.isOpen || token != _closeToken) return;
      if (Get.isRegistered<ApiDetailsController>(tag: widget.api.id)) {
        Get.delete<ApiDetailsController>(tag: widget.api.id);
      }
    });
  }

  void _maybeReturnToDevelopers() {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith(AppRouter.routeDevelopersApi) ||
        path.startsWith(AppRouter.routeDevelopersLibrary)) {
      GoRouter.of(context).go(AppRouter.routeDevelopers);
    }
  }

  void _tryAutoOpen() {
    if (!widget.autoOpen || _didAutoOpen) return;
    _didAutoOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.open();
    });
  }

  void _handleTap(BuildContext context, VoidCallback toggle) {
    final id = widget.api.id;
    if (id.isEmpty) {
      toggle();
      return;
    }
    final target = '${AppRouter.routeDevelopersApi}/$id';
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath == target) {
      toggle();
      return;
    }
    GoRouter.of(context).go(target);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final path = GoRouterState.of(context).uri.path;
      if (path == target && !_controller.isOpen) {
        _controller.open();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: FloatingMenuAnchoredOverlay(
        controller: _controller,
        closeOnScroll: true,
        expandFromAnchor: true,
        panelWidth: double.infinity,
        panelHeight: 1080,
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
        panelChild: ApiDetailsPanel(
          api: widget.api,
          onClose: _controller.close,
        ),
        anchorBuilder: (context, toggle) => InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleTap(context, toggle),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: ApiCardBody(api: widget.api),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: ApiCardBody(api: widget.api),
        ),
      ),
    );
  }
}
