import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../cubits/restaurant_cubit.dart';
import '../../../../shared/widgets/language_toggle_button.dart';

class RestaurantHomeScreen extends StatelessWidget {
  const RestaurantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppLogger.logAuth('Restaurant owner logging out');
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${state.user.name}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your restaurant orders and menu',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }
                    return const Text('Welcome to Restaurant Dashboard');
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending Orders',
                    value: '0',
                    icon: Icons.pending_actions,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Active Orders',
                    value: '0',
                    icon: Icons.restaurant_menu,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _ActionCard(
                  title: 'View Orders',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                  onTap: () {
                    AppLogger.logNavigation('Navigating to restaurant orders');
                    context.push('/restaurant/orders');
                  },
                ),
                _ActionCard(
                  title: 'Manage Products',
                  icon: Icons.restaurant,
                  color: AppColors.success,
                  onTap: () {
                    AppLogger.logNavigation(
                      'Navigating to restaurant products',
                    );
                    context.push('/restaurant/products');
                  },
                ),
                _ActionCard(
                  title: 'Restaurant Settings',
                  icon: Icons.settings,
                  color: AppColors.secondary,
                  onTap: () {
                    AppLogger.logNavigation(
                      'Navigating to restaurant settings',
                    );
                    context.push('/restaurant/settings');
                  },
                ),
                _ActionCard(
                  title: 'Profile',
                  icon: Icons.person,
                  color: AppColors.info,
                  onTap: () {
                    AppLogger.logNavigation('Navigating to profile');
                    // TODO: Navigate to profile
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // My Restaurant Info
            BlocBuilder<RestaurantCubit, RestaurantState>(
              builder: (context, state) {
                if (state is! RestaurantsLoaded) {
                  // Load restaurants if not loaded
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<RestaurantCubit>().getAllRestaurants();
                  });
                  return const SizedBox.shrink();
                }

                if (state.restaurants.isNotEmpty) {
                  final restaurant = state.restaurants.first;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Restaurant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.restaurant, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  restaurant.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  restaurant.address,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: restaurant.isOpen
                                      ? AppColors.success
                                      : AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  restaurant.isOpen ? 'Open' : 'Closed',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
