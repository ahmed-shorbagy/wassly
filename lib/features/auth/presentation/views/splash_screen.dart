import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../cubits/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('Splash screen initialized');
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppLogger.logAuth('Checking current user from splash screen');
        context.read<AuthCubit>().getCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on user type
          final userType = state.user.userType;
          AppLogger.logAuth(
            'User authenticated: ${state.user.name} ($userType)',
          );
          AppLogger.logNavigation('Navigating from splash to home');
          // Navigate to appropriate home based on user type
          if (userType == AppConstants.userTypeCustomer) {
            context.go('/customer');
          } else if (userType == AppConstants.userTypeRestaurant) {
            context.go('/restaurant');
          } else if (userType == AppConstants.userTypeDriver) {
            context.go('/driver');
          } else {
            context.go('/login'); // Unknown user type, go to login
          }
        } else if (state is AuthUnauthenticated) {
          AppLogger.logInfo('User not authenticated, navigating to login');
          context.go('/login');
        } else if (state is AuthError) {
          AppLogger.logWarning(
            'Auth error in splash: ${state.message}, navigating to login',
          );
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return const Icon(
                      Icons.restaurant,
                      size: 60,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
