import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/app_colors.dart';
/// Toast notification types
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Centralized messaging/toast service used across the app.
///
/// This is inspired by the "professional" messaging system you shared:
/// - One unified API for all toasts
/// - Optional [BuildContext] to use themed SnackBars when available
/// - Graceful fallback to `fluttertoast` when no context is provided
/// - Helper methods for success / error / info / warning
/// - Helper to map API messages to localized, user‑friendly text
class ToastService {
  /// Flag to temporarily suppress auth‑related errors during logout or forced redirect.
  static bool _suppressAuthErrors = false;

  /// Call this before starting logout / forced auth redirect flows.
  ///
  /// It will automatically reset after a short delay so that other errors
  /// are not accidentally hidden.
  static void suppressAuthErrors() {
    _suppressAuthErrors = true;
    Future.delayed(const Duration(seconds: 3), () {
      _suppressAuthErrors = false;
    });
  }

  /// Displays a custom toast with an icon and styling based on the [type].
  ///
  /// - If [context] is provided, a nicely styled `SnackBar` using the app theme
  ///   is shown (preferred path).
  /// - If [context] is `null`, we fall back to `Fluttertoast.showToast`
  ///   so cubits/services can still show messages without a context.
  static void showCustomToast({
    required String message,
    ToastType type = ToastType.info,
    Duration? duration,
    BuildContext? context,
  }) {
    // Optionally suppress auth‑related errors during logout
    if (_shouldSuppressMessage(message, type)) return;

    // Preferred: use SnackBar when we have a context
    if (context != null) {
      _showSnackBar(context, message: message, type: type, duration: duration);
      return;
    }

    // Fallback: legacy toast (no context available)
    _showLegacyToast(message: message, type: type, duration: duration);
  }

  /// Maps an API / backend message to a localized, user‑friendly text and shows a toast.
  ///
  /// For errors we keep the message conservative; if it looks too technical,
  /// we fall back to a generic localized error.
  static void showApiMessage({
    required String? apiMessage,
    required BuildContext context,
    ToastType type = ToastType.info,
  }) {
    final resolved = _mapApiMessage(apiMessage, context, type);
    showCustomToast(
      message: resolved,
      type: type,
      context: context,
    );
  }

  // region Convenience helpers

  static void showSuccess(
    String message, {
    Duration? duration,
    BuildContext? context,
  }) {
    showCustomToast(
      message: message,
      type: ToastType.success,
      duration: duration,
      context: context,
    );
  }

  static void showError(
    String message, {
    Duration? duration,
    BuildContext? context,
  }) {
    showCustomToast(
      message: message,
      type: ToastType.error,
      duration: duration,
      context: context,
    );
  }

  static void showInfo(
    String message, {
    Duration? duration,
    BuildContext? context,
  }) {
    showCustomToast(
      message: message,
      type: ToastType.info,
      duration: duration,
      context: context,
    );
  }

  static void showWarning(
    String message, {
    Duration? duration,
    BuildContext? context,
  }) {
    showCustomToast(
      message: message,
      type: ToastType.warning,
      duration: duration,
      context: context,
    );
  }

  // endregion

  // region Internal helpers

  static bool _shouldSuppressMessage(String message, ToastType type) {
    if (!_suppressAuthErrors || type != ToastType.error) return false;

    final lower = message.toLowerCase();
    const authKeywords = [
      'unauthenticated',
      'unauthorized',
      'token',
      'authentication',
      'auth',
    ];

    return authKeywords.any(lower.contains);
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration? duration,
  }) {
    Color background;
    IconData icon;

    switch (type) {
      case ToastType.success:
        background = AppColors.success;
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        background = AppColors.error;
        icon = Icons.error_outline;
        break;
      case ToastType.warning:
        background = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
        background = AppColors.info;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: background,
      duration: duration ?? (type == ToastType.error
          ? const Duration(seconds: 4)
          : const Duration(seconds: 3)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void _showLegacyToast({
    required String message,
    required ToastType type,
    Duration? duration,
  }) {
    Color backgroundColor;
    String icon;
    Toast toastLength;

    switch (type) {
      case ToastType.success:
        backgroundColor = AppColors.success;
        icon = '✅';
        toastLength = Toast.LENGTH_SHORT;
        break;
      case ToastType.error:
        backgroundColor = AppColors.error;
        icon = '❌';
        toastLength = Toast.LENGTH_LONG;
        break;
      case ToastType.warning:
        backgroundColor = AppColors.warning;
        icon = '⚠️';
        toastLength = Toast.LENGTH_SHORT;
        break;
      case ToastType.info:
        backgroundColor = AppColors.info;
        icon = 'ℹ️';
        toastLength = Toast.LENGTH_SHORT;
        break;
    }

    Fluttertoast.showToast(
      msg: '$icon $message',
      toastLength: toastLength,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
      timeInSecForIosWeb: duration != null
          ? duration.inSeconds
          : (type == ToastType.error ? 4 : 3),
    );
  }

  static String _mapApiMessage(
    String? apiMessage,
    BuildContext context,
    ToastType type,
  ) {
    // final l10n = AppLocalizations.of(context);
    // We don't have a dedicated "unexpected_error" key, so we build a safe generic message.
    final genericError =
        'حدث خطأ غير متوقع، برجاء المحاولة مرة أخرى'; // Arabic fallback

    if (apiMessage == null) return genericError;
    final text = apiMessage.trim();
    if (text.isEmpty) return genericError;

    // For info messages we allow short human‑friendly texts from backend.
    if (type != ToastType.error &&
        text.length <= 120 &&
        !text.toLowerCase().contains('exception') &&
        !text.toLowerCase().contains('stacktrace') &&
        !text.toLowerCase().contains('<html')) {
      return text;
    }

    // For errors or technical responses, prefer localized generic message.
    return genericError;
  }

  // endregion
}

