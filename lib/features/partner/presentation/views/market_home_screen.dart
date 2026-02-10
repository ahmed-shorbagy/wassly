import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/language_toggle_button.dart';

class MarketHomeScreen extends StatefulWidget {
  const MarketHomeScreen({super.key});

  @override
  State<MarketHomeScreen> createState() => _MarketHomeScreenState();
}

class _MarketHomeScreenState extends State<MarketHomeScreen> {
  RestaurantEntity? _myMarket;
  List<OrderEntity> _cachedOrders = [];

  void _toggleStatus(bool value) {
    if (_myMarket != null) {
      context.read<RestaurantCubit>().toggleRestaurantStatus(
        _myMarket!.id,
        value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RestaurantCubit, RestaurantState>(
            listener: (context, state) {
              if (state is RestaurantsLoaded && state.restaurants.isNotEmpty) {
                final restaurantId = state.restaurants.first.id;
                _myMarket = state.restaurants.first;
                context.read<OrderCubit>().listenToRestaurantOrders(
                  restaurantId,
                );
              }
            },
          ),
          BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrdersLoaded) {
                setState(() {
                  _cachedOrders = state.orders;
                });
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusSection(context),
                    const SizedBox(height: 24),
                    _buildQuickStats(context),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildMarketCard(context),
                    const SizedBox(height: 32),
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
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.3),
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
                    AppLogger.logAuth('Market owner logging out');
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
                        : context.l10n.welcomeToMarketDashboard,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.manageMarketSubtitle,
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

        if (_cachedOrders.isNotEmpty) {
          pendingCount = _cachedOrders
              .where((o) => o.status == OrderStatus.pending)
              .length;
          activeCount = _cachedOrders
              .where(
                (o) =>
                    o.status == OrderStatus.accepted ||
                    o.status == OrderStatus.preparing ||
                    o.status == OrderStatus.ready,
              )
              .length;

          // Calculate today's earnings
          final now = DateTime.now();
          final todayOrders = _cachedOrders.where(
            (o) =>
                o.createdAt.year == now.year &&
                o.createdAt.month == now.month &&
                o.createdAt.day == now.day &&
                o.status != OrderStatus.cancelled,
          );
          double earnings = 0;
          for (var o in todayOrders) {
            earnings += o.totalAmount;
          }

          return Column(
            children: [
              Row(
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
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.info,
                      gradientColors: [
                        AppColors.info.withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatCard(
                title: context.l10n.totalEarningsToday,
                value:
                    '${earnings.toStringAsFixed(2)} ${context.l10n.currency}',
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.blue,
                gradientColors: [Colors.blue.withOpacity(0.1), Colors.white],
                isFullWidth: true,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final isOpen = _myMarket?.isOpen ?? false;

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
              Icons.storefront_rounded,
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
                      ? context.l10n.acceptingOrders
                      : context.l10n.currentlyOffline,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_myMarket != null)
            Column(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: isOpen,
                    onChanged: _toggleStatus,
                    activeThumbColor: Colors.green,
                    activeTrackColor: Colors.green.withOpacity(0.2),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
                Text(
                  isOpen ? context.l10n.online : context.l10n.offline,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? Colors.green : Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
        ],
      ),
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
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _ActionCard(
              title: context.l10n.viewOrders,
              icon: Icons.receipt_long_rounded,
              color: AppColors.info,
              onTap: () {
                AppLogger.logNavigation('Navigating to market orders');
                context.push('/market/orders');
              },
            ),
            _ActionCard(
              title: context.l10n.manageProducts,
              icon: Icons.inventory_2_rounded,
              color: AppColors.success,
              onTap: () {
                AppLogger.logNavigation('Navigating to market products');
                context.push('/market/products');
              },
            ),
            _ActionCard(
              title: context.l10n.categories,
              icon: Icons.category_rounded,
              color: Colors.purple,
              onTap: () {
                if (_myMarket != null) {
                  context.push(
                    '/market/categories',
                    extra: {'restaurantId': _myMarket!.id},
                  );
                }
              },
            ),
            _ActionCard(
              title: context.l10n.helpSupport,
              icon: Icons.headset_mic_rounded,
              color: Colors.pink,
              onTap: () {
                AppLogger.logNavigation('Navigating to support');
                context.push('/market/support');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketCard(BuildContext context) {
    return BlocBuilder<RestaurantCubit, RestaurantState>(
      builder: (context, state) {
        if (state is! RestaurantsLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<RestaurantCubit>().getAllRestaurants();
          });
          return const SizedBox.shrink();
        }

        if (state.restaurants.isNotEmpty) {
          final market = state.restaurants.first;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.myMarketLabel,
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
                    if (market.imageUrl != null && market.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: market.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
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
                                  market.name,
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
                                        market.address,
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
                              color: market.isOpen
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
                                    color: market.isOpen
                                        ? AppColors.success
                                        : AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  market.isOpen
                                      ? context.l10n.open
                                      : context.l10n.closed,
                                  style: TextStyle(
                                    color: market.isOpen
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
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  final bool isFullWidth;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
