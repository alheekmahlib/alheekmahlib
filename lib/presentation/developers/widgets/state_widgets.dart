import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A loading indicator widget for the developers screen.
///
/// Displays a centered circular progress indicator with appropriate padding.
class DevelopersLoading extends StatelessWidget {
  /// Creates a [DevelopersLoading] widget.
  const DevelopersLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// An empty state widget for the developers screen.
///
/// Displays a centered text message indicating no content is available.
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState] widget.
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'developers_empty'.tr,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// An error state widget for the developers screen.
///
/// Displays a centered text message with the error details.
class ErrorState extends StatelessWidget {
  /// Creates an [ErrorState] widget.
  ///
  /// The [message] parameter is required.
  const ErrorState({
    super.key,
    required this.message,
  });

  /// The error message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontFamily: 'cairo',
          fontSize: 12,
        ),
      ),
    );
  }
}
