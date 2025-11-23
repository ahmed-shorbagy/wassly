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

/// Service for displaying toast notifications across the app
class ToastService {
  /// Displays a custom toast with an icon based on the [type].
  ///
  /// [message] is the text to display.
  /// [type] determines the icon and background color.
  /// [duration] sets how long the toast should be displayed (default: varies by type).
  static void showCustomToast({
    required String message,
    ToastType type = ToastType.info,
    Duration? duration,
  }) {
    Color backgroundColor;
    String icon;
    Toast toastLength;

    // Assign icon, background color, and duration based on the toast type
    switch (type) {
      case ToastType.success:
        backgroundColor = AppColors.success; // Green for success
        icon = "✅";
        toastLength = Toast.LENGTH_SHORT;
        break;
      case ToastType.error:
        backgroundColor = AppColors.error;
        icon = "❌";
        toastLength = Toast.LENGTH_LONG;
        break;
      case ToastType.warning:
        backgroundColor = AppColors.warning;
        icon = "⚠️";
        toastLength = Toast.LENGTH_SHORT;
        break;
      case ToastType.info:
        backgroundColor = AppColors.info;
        icon = "ℹ️";
        toastLength = Toast.LENGTH_SHORT;
        break;
    }

    // Display the toast
    Fluttertoast.showToast(
      msg: "$icon $message",
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

  /// Convenience methods for different toast types
  static void showSuccess(String message, {Duration? duration}) {
    showCustomToast(
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  static void showError(String message, {Duration? duration}) {
    showCustomToast(
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    showCustomToast(
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }

  static void showWarning(String message, {Duration? duration}) {
    showCustomToast(
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }
}

