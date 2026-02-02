import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/language_toggle_button.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../cubits/restaurant_cubit.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  RestaurantEntity? _myRestaurant;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final cubit = context.read<RestaurantCubit>();
    if (cubit.state is! RestaurantsLoaded && cubit.state is! RestaurantLoaded) {
      cubit.getAllRestaurants();
    } else {
      _updateMyRestaurant(cubit.state);
    }
  }

  void _updateMyRestaurant(RestaurantState state) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    if (state is RestaurantsLoaded) {
      try {
        final restaurant = state.restaurants.firstWhere(
          (r) => r.ownerId == authState.user.id,
        );
        setState(() => _myRestaurant = restaurant);
        _subscribeToTopics(restaurant.id);
      } catch (_) {
        // User has no restaurant or not found in list
      }
    } else if (state is RestaurantLoaded) {
      if (state.restaurant.ownerId == authState.user.id) {
        setState(() => _myRestaurant = state.restaurant);
        _subscribeToTopics(state.restaurant.id);
      }
    }
  }

  void _subscribeToTopics(String restaurantId) {
    AppLogger.logInfo(
      'Subscribing to restaurant topic: restaurant_$restaurantId',
    );
    InjectionContainer().notificationService.subscribeToTopic(
      'restaurant_$restaurantId',
    );
    // Listen to orders
    context.read<OrderCubit>().listenToRestaurantOrders(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          _updateMyRestaurant(state);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildQuickStats(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildRestaurantCard(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const LanguageToggleButton(color: Colors.white),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    AppLogger.logAuth('Restaurant owner logging out');
                    context.read<AuthCubit>().logout();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String name = '';
              if (state is AuthAuthenticated) {
                name = state.user.name.split(' ').first;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty
                        ? context.l10n.welcomeName(name)
                        : context.l10n.welcomeToRestaurantDashboard,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.manageRestaurantSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
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
                title: context.l10n.pendingOrders,
                value: pendingCount.toString(),
                icon: Icons.notifications_active_outlined,
                color: AppColors.warning,
                gradientColors: [
                  AppColors.warning.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: context.l10n.activeOrders,
                value: activeCount.toString(),
                icon: Icons.local_dining_outlined,
                color: AppColors.info,
                gradientColors: [AppColors.info.withOpacity(0.1), Colors.white],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.quickActions,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B), // Slate 800
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _ActionCard(
              title: context.l10n.viewOrders,
              icon: Icons.receipt_long_rounded,
              color: AppColors.primary,
              onTap: () {
                AppLogger.logNavigation('Navigating to restaurant orders');
                context.push('/restaurant/orders');
              },
            ),
            _ActionCard(
              title: context.l10n.manageProducts,
              icon: Icons.flatware_rounded,
              color: AppColors.success,
              onTap: () {
                AppLogger.logNavigation('Navigating to restaurant products');
                context.push('/restaurant/products');
              },
            ),
            _ActionCard(
              title: context.l10n.restaurantSettings,
              icon: Icons.storefront_rounded,
              color: AppColors.secondary,
              onTap: () {
                AppLogger.logNavigation('Navigating to restaurant settings');
                context.push('/restaurant/settings');
              },
            ),
            _ActionCard(
              title: context.l10n.profile,
              icon: Icons.person_outline_rounded,
              color: AppColors.info,
              onTap: () {
                AppLogger.logNavigation('Navigating to profile');
                context.push('/profile');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(BuildContext context) {
    if (_myRestaurant == null) {
      return BlocBuilder<RestaurantCubit, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RestaurantError) {
            return Center(child: Text(state.message));
          }
          // If fetching products, we might look like we are loading or have no data
          // But if we truly have no restaurant, we should prompt to create one or wait
          return const SizedBox.shrink();
        },
      );
    }

    final restaurant = _myRestaurant!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.myRestaurant,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              if (restaurant.imageUrl != null &&
                  restaurant.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[100],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  restaurant.address,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: restaurant.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.isOpen
                                ? context.l10n.open
                                : context.l10n.closed,
                            style: TextStyle(
                              color: restaurant.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(icon, size: 100, color: color.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
