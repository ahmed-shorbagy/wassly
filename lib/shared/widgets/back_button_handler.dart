import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

/// Widget that handles back button navigation with confirmation dialogs
/// Prevents accidental app closure and handles navigation properly
class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final bool canPop;
  final String? customMessage;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.canPop = true,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        final canPopRoute = router.canPop();
        final currentLocation = router.routeInformationProvider.value.uri.path;

        // If we can pop a route, do it normally
        if (canPopRoute) {
          router.pop();
          return;
        }

        // If we're at the root and user tries to go back
        if (!canPopRoute) {
          // If we're already at home, show exit confirmation
          if (currentLocation == '/home') {
            final shouldExit = await _showExitConfirmation(context);
            if (shouldExit && context.mounted) {
              // Exit the app
              // Note: On mobile, this might not work as expected
              // The system handles app lifecycle
            }
          } else {
            // If we're not at home and can't pop, navigate to home
            // This ensures proper navigation stack and prevents app closure
            if (context.mounted) {
              router.go('/home');
            }
          }
        }
      },
      child: child,
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final message = customMessage ?? l10n?.exitAppConfirmation ?? 'هل أنت متأكد من الخروج من التطبيق؟';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.exitApp ?? 'الخروج'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.exit ?? 'خروج'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

/// Wrapper for screens that need back button handling with unsaved changes warning
class UnsavedChangesHandler extends StatelessWidget {
  final Widget child;
  final bool hasUnsavedChanges;
  final String? customMessage;

  const UnsavedChangesHandler({
    super.key,
    required this.child,
    this.hasUnsavedChanges = false,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop || !hasUnsavedChanges) return;

        final router = GoRouter.of(context);
        final canPopRoute = router.canPop();

        if (canPopRoute) {
          final shouldDiscard = await _showUnsavedChangesDialog(context);
          if (shouldDiscard && context.mounted) {
            router.pop();
          }
        }
      },
      child: child,
    );
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final message = customMessage ??
        l10n?.unsavedChangesWarning ??
        'لديك تغييرات غير محفوظة. هل تريد تجاهلها والمتابعة؟';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.unsavedChanges ?? 'تغييرات غير محفوظة'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.discard ?? 'تجاهل'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

