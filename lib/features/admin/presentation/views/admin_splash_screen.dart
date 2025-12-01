import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/app_colors.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('Admin Splash screen initialized - No authentication required');
    _navigateToDashboard();
  }

  Future<void> _navigateToDashboard() async {
    // Wait for a short delay to show splash
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      AppLogger.logInfo('Navigating to admin dashboard - Direct access, no auth required');
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.promoBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpeg',
              fit: BoxFit.contain,
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
