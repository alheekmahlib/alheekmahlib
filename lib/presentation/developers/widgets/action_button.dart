import 'package:flutter/material.dart';

/// A styled elevated button with an icon and label.
///
/// Used for action buttons in the developers screen, such as
/// opening documentation, GitHub, or downloading resources.
class ActionButton extends StatelessWidget {
  /// Creates an [ActionButton].
  ///
  /// The [icon], [label], and [onTap] parameters are required.
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.minimumSize,
  });

  /// The icon to display on the button.
  final IconData icon;

  /// The label text to display on the button.
  final String label;

  /// The callback to invoke when the button is tapped.
  final VoidCallback onTap;

  final Size? minimumSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'cairo'),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
        minimumSize: minimumSize,
      ),
    );
  }
}
