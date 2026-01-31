import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/language_toggle_button.dart';

import '../../../orders/presentation/cubits/order_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';

class MarketHomeScreen extends StatelessWidget {
  const MarketHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Dashboard'),
        actions: [
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppLogger.logAuth('Market owner logging out');
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: BlocListener<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantsLoaded && state.restaurants.isNotEmpty) {
            final restaurantId = state.restaurants.first.id;
            AppLogger.logInfo(
              'Subscribing to market topic: restaurant_$restaurantId',
            );
            InjectionContainer().notificationService.subscribeToTopic(
              'restaurant_$restaurantId',
            );
            // Listen to orders
            context.read<OrderCubit>().listenToRestaurantOrders(restaurantId);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.blue.withValues(alpha: 0.1),
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
                              'Manage your market inventory and orders',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text('Welcome to Market Dashboard');
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

              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  int pendingCount = 0;
                  int activeCount = 0;

                  if (state is OrdersLoaded) {
                    pendingCount = state.orders
                        .where((o) => o.status == OrderStatus.pending)
                        .length;
                    activeCount = state.orders
                        .where(
                          (o) =>
                              o.status == OrderStatus.accepted ||
                              o.status == OrderStatus.preparing ||
                              o.status == OrderStatus.ready,
                        )
                        .length;
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Pending Orders',
                          value: pendingCount.toString(),
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Active Orders',
                          value: activeCount.toString(),
                          icon: Icons.shopping_bag,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  );
                },
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
                      AppLogger.logNavigation('Navigating to market orders');
                      context.push('/market/orders');
                    },
                  ),
                  _ActionCard(
                    title: 'Manage Products',
                    icon: Icons.inventory_2,
                    color: AppColors.success,
                    onTap: () {
                      AppLogger.logNavigation('Navigating to market products');
                      context.push('/market/products');
                    },
                  ),
                  _ActionCard(
                    title: 'Market Settings',
                    icon: Icons.settings,
                    color: AppColors.secondary,
                    onTap: () {
                      AppLogger.logNavigation('Navigating to market settings');
                      context.push('/market/settings');
                    },
                  ),
                  _ActionCard(
                    title: 'Profile',
                    icon: Icons.person,
                    color: AppColors.info,
                    onTap: () {
                      AppLogger.logNavigation('Navigating to profile');
                      context.push('/profile');
                    },
                  ),
                ],
              ),
            ],
          ),
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
