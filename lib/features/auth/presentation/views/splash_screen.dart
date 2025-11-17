import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/favorites_cubit.dart';
import '../../../ads/presentation/cubits/startup_ad_customer_cubit.dart';
import '../../../ads/domain/entities/startup_ad_entity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentAdIndex = 0;
  bool _showAd = false;
  List<StartupAdEntity> _startupAds = [];

  @override
  void initState() {
    super.initState();
    AppLogger.logInfo('Splash screen initialized');
    // Load startup ads first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StartupAdCustomerCubit>().loadActiveStartupAds();
      }
    });
  }

  void _handleAdTap(StartupAdEntity ad) {
    if (ad.deepLink != null && ad.deepLink!.isNotEmpty) {
      // Handle deep link navigation
      try {
        context.push(ad.deepLink!);
      } catch (e) {
        AppLogger.logError('Failed to navigate to deep link', error: e);
      }
    }
  }

  void _skipAd() {
    setState(() {
      _showAd = false;
    });
    _checkAuth();
  }

  void _checkAuth() {
    AppLogger.logAuth('Checking current user from splash screen');
    context.read<AuthCubit>().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StartupAdCustomerCubit, StartupAdCustomerState>(
          listener: (context, state) {
            if (state is StartupAdCustomerLoaded) {
              if (state.ads.isNotEmpty) {
                setState(() {
                  _startupAds = state.ads;
                  _showAd = true;
                });
                // Auto-advance ads every 3 seconds
                if (state.ads.length > 1) {
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted && _showAd) {
                      setState(() {
                        _currentAdIndex =
                            (_currentAdIndex + 1) % state.ads.length;
                      });
                    }
                  });
                }
                // Auto-skip after 5 seconds
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted && _showAd) {
                    _skipAd();
                  }
                });
              } else {
                _checkAuth();
              }
            } else if (state is StartupAdCustomerError) {
              // If error loading ads, just proceed to auth check
              _checkAuth();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (!_showAd) {
              // Only handle auth navigation if not showing ad
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
            }
          },
        ),
      ],
      child: Scaffold(
        body: _showAd && _startupAds.isNotEmpty
            ? _buildStartupAdView()
            : _buildSplashView(),
      ),
    );
  }

  Widget _buildStartupAdView() {
    final ad = _startupAds[_currentAdIndex];
    return GestureDetector(
      onTap: () => _handleAdTap(ad),
      child: Stack(
        children: [
          // Ad Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: ad.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.primary,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => _buildSplashView(),
            ),
          ),
          // Skip Button
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: _skipAd,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Ad Info Overlay (if title or description exists)
          if (ad.title != null || ad.description != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ad.title != null)
                      Text(
                        ad.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (ad.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        ad.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Page Indicators
          if (_startupAds.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_startupAds.length, (index) {
                  return Container(
                    width: _currentAdIndex == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentAdIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSplashView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        children: [
          // subtle decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: _DecorativeCircle(size: 180, color: Colors.white24),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _DecorativeCircle(size: 220, color: Colors.white10),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutBack,
                  builder: (_, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'وصلي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Opacity(
                  opacity: 0.9,
                  child: Text(
                    'أسرع طريقة لطلب طعامك',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 28),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
