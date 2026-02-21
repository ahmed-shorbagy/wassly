import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/flavor_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';
import '../cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/favorites_cubit.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuth();
      }
    });
  }

  void _checkAuth() {
    AppLogger.logAuth('Checking current user from splash screen');
    context.read<AuthCubit>().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          final userType = user.userType;
          AppLogger.logAuth('User authenticated: ${user.name} ($userType)');

          // Start favorites sync if applicable
          try {
            context.read<FavoritesCubit>().start();
          } catch (_) {}

          AppLogger.logNavigation('Navigating from splash based on user type');

          final flavor = FlavorConfig.instance;

          // Route based on flavor and user type
          if (flavor.isCustomerApp()) {
            if (userType == AppConstants.userTypeCustomer) {
              context.pushReplacement('/home');
            } else {
              // Non-customer in customer app
              context.pushReplacement('/login');
              context.showErrorSnackBar('This app is for customers only.');
            }
          } else if (flavor.isPartnerApp()) {
            if (userType == AppConstants.userTypeRestaurant) {
              context.pushReplacement('/restaurant');
            } else if (userType == AppConstants.userTypeDriver) {
              context.pushReplacement('/driver');
            } else if (userType == AppConstants.userTypeMarket) {
              context.pushReplacement('/market');
            } else {
              // Non-partner in partner app
              context.pushReplacement('/login');
              context.showErrorSnackBar('This app is for partners only.');
            }
          } else if (flavor.isAdminApp()) {
            if (userType == AppConstants.userTypeAdmin) {
              context.pushReplacement('/admin');
            } else {
              context.pushReplacement('/login');
            }
          } else {
            // General app (AppRouter) - route everywhere
            if (userType == AppConstants.userTypeCustomer) {
              context.pushReplacement('/home');
            } else if (userType == AppConstants.userTypeRestaurant) {
              context.pushReplacement('/restaurant');
            } else if (userType == AppConstants.userTypeDriver) {
              context.pushReplacement('/driver');
            } else {
              context.pushReplacement('/home');
            }
          }
        } else if (state is AuthUnauthenticated) {
          AppLogger.logInfo('User not authenticated, navigating to login');
          context.pushReplacement('/login');
        }
        // AuthError is handled in the UI with a retry button
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Center(
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
                        Icons.restaurant,
                        size: 80,
                        color: AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  if (state is AuthError) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _checkAuth,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pushReplacement('/login'),
                      child: const Text('Go to Login'),
                    ),
                  ] else ...[
                    const CircularProgressIndicator(color: AppColors.primary),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
