import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;
  String? _driverId;
  String? _driverName;
  String? _driverPhone;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _driverId = authState.user.id;
        _driverName = authState.user.name;
        _driverPhone = authState.user.phone;
      });
      // Load available orders
      context.read<OrderCubit>().listenToAvailableOrders();
    }
  }

  void _toggleOnlineStatus(bool value) {
    setState(() {
      _isOnline = value;
      AppLogger.logInfo('Driver ${_isOnline ? "went online" : "went offline"}');
    });
    if (_isOnline) {
      context.read<OrderCubit>().listenToAvailableOrders();
    }
  }

  Future<void> _acceptOrder(OrderEntity order) async {
    if (_driverId == null || _driverName == null || _driverPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver information not available')),
      );
      return;
    }

    AppLogger.logInfo('Driver accepting order: ${order.id}');
    await context.read<OrderCubit>().assignDriverToOrder(
          order.id,
          _driverId!,
          _driverName!,
          _driverPhone!,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order accepted! Navigate to pickup location.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driver),
        actions: [
          // Online/Offline Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isOnline
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? AppColors.success : AppColors.error,
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: _toggleOnlineStatus,
                  activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.success,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppLogger.logAuth('Driver logging out');
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDriverData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              _buildStatusCard(),

              const SizedBox(height: 24),

              // Today's Stats
              _buildTodaysStats(l10n),

              const SizedBox(height: 24),

              // Available Orders
              _buildAvailableOrdersSection(l10n),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isOnline
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.error.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.error.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isOnline ? Icons.delivery_dining : Icons.car_repair,
                      size: 36,
                      color: _isOnline ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${state.user.name}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isOnline
                              ? 'You are online and available for deliveries'
                              : 'Go online to start receiving orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isOnline
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Text('Welcome to Driver Dashboard');
          },
        ),
      ),
    );
  }

  Widget _buildTodaysStats(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Performance',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Deliveries',
                value: '0',
                icon: Icons.delivery_dining,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Earnings',
                value: '0 ${l10n.currencySymbol}',
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Rating',
                value: '5.0',
                icon: Icons.star,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isOnline ? 'Available Orders' : 'My Orders',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                AppLogger.logNavigation('Navigating to driver orders');
                context.push('/driver/orders');
              },
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!_isOnline)
          _buildGoOnlineCard()
        else
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is OrdersLoaded) {
                final availableOrders = state.orders
                    .where((o) =>
                        o.status == OrderStatus.ready &&
                        (o.driverId == null || o.driverId!.isEmpty))
                    .toList();

                if (availableOrders.isEmpty) {
                  return _buildNoOrdersCard();
                }

                return Column(
                  children: availableOrders
                      .take(3)
                      .map((order) => _buildOrderCard(order, l10n))
                      .toList(),
                );
              }

              if (state is OrderError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<OrderCubit>().listenToAvailableOrders();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _buildNoOrdersCard();
            },
          ),
      ],
    );
  }

  Widget _buildGoOnlineCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.power_settings_new,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Go Online to Receive Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toggle the switch in the app bar to start receiving delivery orders',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoOrdersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Available Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New orders will appear here when restaurants mark them as ready',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.restaurantName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.ready,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: TextStyle(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.total}: ${order.totalAmount.toStringAsFixed(2)} ${l10n.currencySymbol}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${order.items.length} ${l10n.items}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _acceptOrder(order),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.accept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              title: l10n.orders,
              icon: Icons.receipt_long,
              color: AppColors.primary,
              onTap: () {
                AppLogger.logNavigation('Navigating to driver orders');
                context.push('/driver/orders');
              },
            ),
            _ActionCard(
              title: l10n.profile,
              icon: Icons.person,
              color: AppColors.info,
              onTap: () {
                AppLogger.logNavigation('Navigating to driver profile');
                context.push('/driver/profile');
              },
            ),
          ],
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
