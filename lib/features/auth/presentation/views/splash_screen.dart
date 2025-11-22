import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
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
    // Check auth immediately - ads will be shown as popup in home screen
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
                // Navigate based on user type
                final userType = state.user.userType;
                AppLogger.logAuth(
                  'User authenticated: ${state.user.name} ($userType)',
                );
                // Start cloud favorites sync for this user
                try {
                  context.read<FavoritesCubit>().start();
                } catch (_) {}
                AppLogger.logNavigation('Navigating from splash to home');
                // Customer app - only navigate to home for customers
                // Other user types should use their respective apps
                if (userType == AppConstants.userTypeCustomer) {
                  context.pushReplacement('/home');
                } else {
                  // For non-customer users, show error or redirect to login
                  context.pushReplacement('/login');
                }
              } else if (state is AuthUnauthenticated) {
                AppLogger.logInfo(
                  'User not authenticated, navigating to login',
                );
                context.pushReplacement('/login');
              } else if (state is AuthError) {
                AppLogger.logWarning(
                  'Auth error in splash: ${state.message}, navigating to login',
                );
                context.pushReplacement('/login');
              }
              // Note: AuthInitial and AuthLoading states are handled by showing the loading indicator
          },
        ),
      ],
      child: Scaffold(
        body: _buildSplashView(),
      ),
    );
  }


  Widget _buildSplashView() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.promoBackground, // Light pastel green background
      ),
      child: Center(
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

