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
    AppLogger.logInfo('Admin Splash screen initialized');
    _navigateToDashboard();
  }

  Future<void> _navigateToDashboard() async {
    // Wait for a short delay to show splash
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      AppLogger.logInfo('Navigating to admin dashboard');
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.promoBackground, // Light pastel green background
      body: Center(
        child: Image.asset(
          'assets/images/logo.jpeg',
          fit: BoxFit.contain,
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.restaurant,
              size: 80,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}

