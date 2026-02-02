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

  void _toggleStatus(bool isOpen) {
    if (_myRestaurant == null) return;

    // Optimistic update locally
    setState(() {
      _myRestaurant = _myRestaurant!.copyWith(isOpen: isOpen);
    });

    context.read<RestaurantCubit>().toggleRestaurantStatus(
      _myRestaurant!.id,
      isOpen,
    );
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
                    _buildStatusSection(context),
                    const SizedBox(height: 24),
                    _buildQuickStats(context),
                    const SizedBox(height: 32),
                    Text(
                      context.l10n.quickActions,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B), // Slate 800
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionGrid(context),
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
        color: AppColors.primary,
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
              String email = '';
              if (state is AuthAuthenticated) {
                name = state.user.name.split(' ').first;
                email = state.user.email;
              }
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'R',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.welcomeName(name),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_myRestaurant != null)
                          Text(
                            _myRestaurant!.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          )
                        else
                          Text(
                            email, // Fallback if no restaurant loaded yet
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
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

  Widget _buildStatusSection(BuildContext context) {
    final isOpen = _myRestaurant?.isOpen ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOpen
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_mall_directory_rounded,
              color: isOpen ? Colors.green : Colors.red,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? context.l10n.open : context.l10n.closed,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  isOpen
                      ? 'You are accepting orders'
                      : 'You are currently offline',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_myRestaurant != null)
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isOpen,
                onChanged: _toggleStatus,
                activeThumbColor: Colors.green,
                activeTrackColor: Colors.green.withOpacity(0.2),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.2),
              ),
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
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFFFF9F1C), // Orange
                bgColor: const Color(0xFFFFF4E5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: context.l10n.activeOrders,
                value: activeCount.toString(),
                icon: Icons.soup_kitchen_rounded,
                color: const Color(0xFF2EC4B6), // Teal
                bgColor: const Color(0xFFE8F9F8),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        title: context.l10n.addProduct,
        icon: Icons.add_circle_rounded,
        color: Colors.blue,
        onTap: () => context.push('/restaurant/products/add'),
        isPrimary: true,
      ),
      _ActionItem(
        title: context.l10n.manageProducts,
        icon: Icons.restaurant_menu_rounded,
        color: Colors.orange,
        onTap: () => context.push('/restaurant/products'),
      ),
      _ActionItem(
        title: 'Categories',
        icon: Icons.category_rounded,
        color: Colors.purple,
        onTap: () {
          if (_myRestaurant != null) {
            context.push(
              '/restaurant/categories',
              extra: {'restaurantId': _myRestaurant!.id},
            );
          }
        },
      ),
      _ActionItem(
        title: context.l10n.viewOrders,
        icon: Icons.receipt_long_rounded,
        color: Colors.teal,
        onTap: () => context.push('/restaurant/orders'),
      ),
      _ActionItem(
        title: 'Reviews',
        icon: Icons.star_rounded,
        color: Colors.amber,
        onTap: () => context.push('/restaurant/reviews'),
      ),
      _ActionItem(
        title: 'Support',
        icon: Icons.headset_mic_rounded,
        color: Colors.pink,
        onTap: () => context.push('/restaurant/support'),
      ),
      _ActionItem(
        title: context.l10n.restaurantSettings,
        icon: Icons.settings_rounded,
        color: Colors.grey,
        onTap: () => context.push('/restaurant/settings'),
      ),
      _ActionItem(
        title: context.l10n.profile,
        icon: Icons.person_rounded,
        color: Colors.indigo,
        onTap: () => context.push('/profile'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actions.map((action) {
            final width = (constraints.maxWidth - 16) / 2;
            return SizedBox(
              width: width,
              child: _ActionCard(item: action),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  _ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;

  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
