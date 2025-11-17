import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrapper widget that ensures proper back button navigation
/// Prevents app from closing unexpectedly and handles navigation correctly
class SafeNavigationWrapper extends StatelessWidget {
  final Widget child;
  final String? fallbackRoute;
  final bool canPop;

  const SafeNavigationWrapper({
    super.key,
    required this.child,
    this.fallbackRoute,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // If we can pop normally, do it
        if (context.canPop()) {
          context.pop();
        } else {
          // If we're at root and have a fallback route, navigate there
          if (fallbackRoute != null) {
            context.go(fallbackRoute!);
          } else {
            // Default: try to go to admin dashboard
            if (context.canPop()) {
              context.pop();
            } else {
              // Last resort: navigate to admin dashboard
              context.go('/admin');
            }
          }
        }
      },
      child: child,
    );
  }
}

