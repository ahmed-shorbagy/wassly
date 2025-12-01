import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../cubits/auth_cubit.dart';

/// Splash screen for Partner app (Restaurant owners and Drivers)
class PartnerSplashScreen extends StatefulWidget {
  const PartnerSplashScreen({super.key});

  @override
  State<PartnerSplashScreen> createState() => _PartnerSplashScreenState();
}

class _PartnerSplashScreenState extends State<PartnerSplashScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('Partner Splash screen initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuth();
      }
    });
  }

  void _checkAuth() {
    AppLogger.logAuth('Checking current user from partner splash screen');
    context.read<AuthCubit>().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final userType = state.user.userType;
          AppLogger.logAuth('User authenticated: ${state.user.name} ($userType)');

          // Route based on user type
          if (userType == AppConstants.userTypeRestaurant) {
            AppLogger.logNavigation('Restaurant user, navigating to restaurant home');
            context.pushReplacement('/restaurant');
          } else if (userType == AppConstants.userTypeDriver) {
            AppLogger.logNavigation('Driver user, navigating to driver home');
            context.pushReplacement('/driver');
          } else {
            AppLogger.logWarning('Non-partner user trying to access partner app');
            _showAccessDenied(context, userType);
          }
        } else if (state is AuthUnauthenticated) {
          AppLogger.logInfo('User not authenticated, navigating to login');
          context.pushReplacement('/login');
        } else if (state is AuthError) {
          AppLogger.logWarning('Auth error in splash: ${state.message}');
          context.pushReplacement('/login');
        }
      },
      child: Scaffold(
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
                    Icons.delivery_dining,
                    size: 80,
                    color: AppColors.primary,
                  );
                },
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccessDenied(BuildContext context, String userType) {
    String message;
    if (userType == AppConstants.userTypeCustomer) {
      message = 'This app is for restaurant partners and drivers. Please use the customer app.';
    } else {
      message = 'You do not have access to this app. Please login with a valid partner account.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
              context.pushReplacement('/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

