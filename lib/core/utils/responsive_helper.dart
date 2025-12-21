import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Responsive helper utility class for consistent sizing across all screen sizes
class ResponsiveHelper {
  /// Get responsive width
  static double width(double width) => width.w;

  /// Get responsive height
  static double height(double height) => height.h;

  /// Get responsive font size
  static double fontSize(double size) => size.sp;

  /// Get responsive radius
  static double radius(double radius) => radius.r;

  /// Get responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all.w);
    }
    return EdgeInsets.only(
      top: (top ?? vertical ?? 0).h,
      bottom: (bottom ?? vertical ?? 0).h,
      left: (left ?? horizontal ?? 0).w,
      right: (right ?? horizontal ?? 0).w,
    );
  }

  /// Get responsive margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all.w);
    }
    return EdgeInsets.only(
      top: (top ?? vertical ?? 0).h,
      bottom: (bottom ?? vertical ?? 0).h,
      left: (left ?? horizontal ?? 0).w,
      right: (right ?? horizontal ?? 0).w,
    );
  }

  /// Get responsive spacing
  static SizedBox spacing({double? width, double? height}) {
    return SizedBox(
      width: width?.w,
      height: height?.h,
    );
  }

  /// Get responsive app bar height (optimized for different screen sizes)
  static double getAppBarHeight(BuildContext context) {
    final screenHeight = ScreenUtil().screenHeight;
    if (screenHeight < 600) {
      // Small screens
      return 80.h;
    } else if (screenHeight < 800) {
      // Medium screens
      return 90.h;
    } else {
      // Large screens
      return 100.h;
    }
  }

  /// Get responsive bottom nav bar height
  static double getBottomNavBarHeight() => 60.h;

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return ScreenUtil().screenWidth < 360;
  }

  /// Check if screen is medium
  static bool isMediumScreen(BuildContext context) {
    final width = ScreenUtil().screenWidth;
    return width >= 360 && width < 600;
  }

  /// Check if screen is large
  static bool isLargeScreen(BuildContext context) {
    return ScreenUtil().screenWidth >= 600;
  }

  /// Get responsive icon size
  static double iconSize(double size) => size.sp;

  /// Get responsive aspect ratio for grid items
  static double getGridAspectRatio(BuildContext context) {
    final screenWidth = ScreenUtil().screenWidth;
    if (screenWidth < 350) {
      return 0.60;
    } else if (screenWidth < 400) {
      return 0.62;
    } else {
      return 0.63;
    }
  }
}

