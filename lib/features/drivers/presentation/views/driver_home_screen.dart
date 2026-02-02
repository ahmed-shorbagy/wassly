import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/language_toggle_button.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';
import '../../../orders/domain/repositories/order_repository.dart';

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
  bool _isLoading = false;

  // Stats
  double _todayEarnings = 0;
  int _todayDeliveries = 0;

  // Active Order (Assigned to driver but not completed)
  OrderEntity? _activeOrder;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _driverId = authState.user.id;
          _driverName = authState.user.name;
          _driverPhone = authState.user.phone;
        });
      }
      // If online, listen to new orders
      if (_isOnline) {
        context.read<OrderCubit>().listenToAvailableOrders();
      }
      await _refreshDashboard();
    }
  }

  Future<void> _refreshDashboard() async {
    if (_driverId == null) return;
    setState(() => _isLoading = true);

    try {
      final repo = context.read<OrderRepository>();
      final result = await repo.getDriverOrders(_driverId!);

      result.fold(
        (failure) => AppLogger.logError(
          'Failed to load dashboard data',
          error: failure.message,
        ),
        (orders) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // 1. Calculate Today's Stats
          final todayCompletedOrders = orders.where((o) {
            return o.status == OrderStatus.delivered &&
                o.updatedAt.isAfter(today);
          }).toList();

          // 2. Find Active Order (Assigned to me, not delivered/cancelled)
          final active = orders.where((o) {
            return o.driverId == _driverId &&
                o.status != OrderStatus.delivered &&
                o.status != OrderStatus.cancelled;
          }).toList();

          // Sort by date to get most recent active order if multiple (edge case)
          active.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          if (mounted) {
            setState(() {
              _todayDeliveries = todayCompletedOrders.length;
              _todayEarnings = todayCompletedOrders.fold(
                0.0,
                (sum, order) => sum + order.totalAmount,
              );
              _activeOrder = active.isNotEmpty ? active.first : null;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.logError('Error refreshing dashboard', error: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleStatus(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });

    if (isOnline) {
      context.read<OrderCubit>().listenToAvailableOrders();
      _refreshDashboard();
    } else {
      // Maybe stop listening or just update UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildStatusCard(),
                          const SizedBox(height: 24),
                          _buildMainContent(),
                          const SizedBox(height: 24),
                          _buildStatsRow(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _driverName ?? context.l10n.driver,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isOnline)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.online,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              context.l10n.offline,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
      actions: [
        const LanguageToggleButton(color: Color(0xFF1E293B)),
        IconButton(
          onPressed: () => context.push('/driver/profile'),
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isOnline ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isOnline
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isOnline
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF10B981) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              color: _isOnline ? Colors.white : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline
                      ? context.l10n.youAreOnline
                      : context.l10n.youAreOffline,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isOnline
                        ? const Color(0xFF065F46)
                        : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  _isOnline
                      ? context.l10n.waitingForOrders
                      : context.l10n.goOnlineToAcceptOrders,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isOnline
                        ? const Color(0xFF047857)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isOnline,
            onChanged: _toggleStatus,
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // 1. If Offline
    if (!_isOnline) {
      return _buildOfflineState();
    }

    // 2. If Active Order Exists
    if (_activeOrder != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context.l10n.activeOrder,
            icon: Icons.delivery_dining,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildActiveOrderCard(_activeOrder!),
        ],
      );
    }

    // 3. If Online & No Active Order -> Show Available Orders
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context.l10n.availableOrders,
          icon: Icons.notifications_active,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAvailableOrdersList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? color}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.coffee_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            context.l10n.takeBreakOrGoOnline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(OrderEntity order) {
    return GestureDetector(
      onTap: () {
        // Navigate to details to complete actions
        // context.push('/driver/order/${order.id}');
        // For now, implementing basic actions here would require a lot of state management duplication
        // Ideally we push to a dedicated OrderDetailsScreen.
        // Assuming we have one, or repurposing a simple details view.
        // Let's assume we can navigate to list for now or expand this card.
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Map Placeholder or Mini Map
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/map_placeholder.png',
                  ), // Fallback if no asset
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.navigation,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.status == OrderStatus.pickedUp
                            ? context.l10n.toCustomer
                            : context.l10n.toRestaurant,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.restaurantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${order.id.substring(0, 6).toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    isActive: order.status != OrderStatus.pickedUp,
                    isCompleted: order.status == OrderStatus.pickedUp,
                    icon: Icons.storefront_rounded,
                    title: context.l10n.pickUp,
                    subtitle:
                        order.restaurantName, // Could be address if available
                    isLast: false,
                  ),
                  _buildStep(
                    isActive: order.status == OrderStatus.pickedUp,
                    isCompleted: false,
                    icon: Icons.location_on_rounded,
                    title: context.l10n.dropoff,
                    subtitle: order.deliveryAddress,
                    isLast: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Action based on status
                        if (order.status == OrderStatus.accepted ||
                            order.status == OrderStatus.preparing ||
                            order.status == OrderStatus.ready) {
                          _updateOrderStatus(order, OrderStatus.pickedUp);
                        } else if (order.status == OrderStatus.pickedUp) {
                          _updateOrderStatus(order, OrderStatus.delivered);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        order.status == OrderStatus.pickedUp
                            ? context.l10n.swipeToComplete
                            : context.l10n.confirmPickup,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildStep({
    required bool isActive,
    required bool isCompleted,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    final color = isCompleted
        ? Colors.green
        : (isActive ? AppColors.primary : Colors.grey);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? Colors.green.withOpacity(0.5)
                        : Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersList() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrdersLoaded) {
          final available = state.orders
              .where((o) => o.status == OrderStatus.ready && o.driverId == null)
              .toList();

          if (available.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.radar_rounded,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.scanningArea,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.noOrdersNearby,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: available.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = available[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.restaurantName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            context.l10n.estEarnings(
                              order.totalAmount.toString(),
                              context.l10n.currencySymbol,
                            ),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _acceptOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        context.l10n.accept,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: context.l10n.earnings,
            value: '$_todayEarnings',
            suffix: context.l10n.currencySymbol,
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: context.l10n.deliveries,
            value: '$_todayDeliveries',
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickAction(
          icon: Icons.history_rounded,
          label: context.l10n.history,
          onTap: () => context.push('/driver/orders'),
        ),
        _QuickAction(
          icon: Icons.person_rounded,
          label: context.l10n.profile,
          onTap: () => context.push('/driver/profile'),
        ),
        _QuickAction(
          icon: Icons.settings_rounded,
          label: context.l10n.settings,
          onTap: () {},
        ),
      ],
    );
  }

  Future<void> _acceptOrder(OrderEntity order) async {
    if (_driverId == null) return;
    try {
      await context.read<OrderRepository>().assignDriverToOrder(
        order.id,
        _driverId!,
        _driverName ?? context.l10n.driverRole,
        _driverPhone ?? '',
      );
      await _refreshDashboard();
      context.showSuccessSnackBar(context.l10n.orderAcceptedExclamation);
    } catch (e) {
      context.showErrorSnackBar(context.l10n.failedToAcceptOrder);
    }
  }

  Future<void> _updateOrderStatus(
    OrderEntity order,
    OrderStatus newStatus,
  ) async {
    try {
      await context.read<OrderRepository>().updateOrderStatus(
        order.id,
        newStatus,
      );
      await _refreshDashboard();
      if (newStatus == OrderStatus.delivered) {
        context.showSuccessSnackBar(context.l10n.orderDeliveredSuccessfully);
      }
    } catch (e) {
      context.showErrorSnackBar(context.l10n.failedToUpdateStatus);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.suffix,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    suffix!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
