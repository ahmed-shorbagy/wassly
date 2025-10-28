import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, {String? tag}) {
    final timestamp = DateTime.now().toString();
    final logTag = tag != null ? '[$tag]' : '';
    debugPrint('📱 $timestamp $logTag $message');
  }

  static void logInfo(String message) {
    log('ℹ️ INFO: $message', tag: 'INFO');
  }

  static void logSuccess(String message) {
    log('✅ SUCCESS: $message', tag: 'SUCCESS');
  }

  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    log('❌ ERROR: $message', tag: 'ERROR');
    if (error != null) {
      log('Error details: $error', tag: 'ERROR');
    }
    if (stackTrace != null) {
      log('Stack trace: $stackTrace', tag: 'ERROR');
    }
  }

  static void logWarning(String message) {
    log('⚠️ WARNING: $message', tag: 'WARNING');
  }

  static void logNavigation(String route) {
    log('🧭 NAVIGATION: Navigating to $route', tag: 'NAV');
  }

  static void logAuth(String message) {
    log('🔐 AUTH: $message', tag: 'AUTH');
  }

  static void logCart(String message) {
    log('🛒 CART: $message', tag: 'CART');
  }

  static void logOrder(String message) {
    log('📦 ORDER: $message', tag: 'ORDER');
  }
}
