import 'package:floating_menu_expendable/floating.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/helpers/app_router.dart';
import '../../models/developer_models.dart';
import 'library_card_body.dart';
import 'library_details_panel.dart';

/// A card widget for displaying library items with expandable details.
///
/// Uses [FloatingMenuAnchoredOverlay] to show a panel with detailed
/// library information when tapped.
class DeveloperLibraryCard extends StatefulWidget {
  /// Creates a [DeveloperLibraryCard].
  const DeveloperLibraryCard({
    super.key,
    required this.item,
    this.autoOpen = false,
  });

  /// The library item to display.
  final DeveloperItem item;
  final bool autoOpen;

  @override
  State<DeveloperLibraryCard> createState() => _DeveloperLibraryCardState();
}

class _DeveloperLibraryCardState extends State<DeveloperLibraryCard> {
  late final FloatingMenuAnchoredOverlayController _controller =
      FloatingMenuAnchoredOverlayController();
  bool _didAutoOpen = false;
  bool _wasOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
    _tryAutoOpen();
  }

  @override
  void didUpdateWidget(covariant DeveloperLibraryCard oldWidget) {
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
    }
    _wasOpen = isOpen;
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
    final id = widget.item.id;
    if (id.isEmpty) {
      toggle();
      return;
    }
    final target = '${AppRouter.routeDevelopersLibrary}/$id';
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
        panelChild: LibraryDetailsPanel(
          item: widget.item,
          onClose: _controller.close,
        ),
        anchorBuilder: (context, toggle) => InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _handleTap(context, toggle),
          child: LibraryCardBody(item: widget.item),
        ),
        child: LibraryCardBody(item: widget.item),
      ),
    );
  }
}
