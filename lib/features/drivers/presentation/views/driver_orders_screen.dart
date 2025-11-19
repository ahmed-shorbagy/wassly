import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDriverAndOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDriverAndOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _driverId = authState.user.id;
      });
      // Load driver's orders
      // Note: This would need a getDriverOrders method in OrderRepository
      context.read<OrderCubit>().getAllOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.activeOrders),
            Tab(text: l10n.orderHistory),
          ],
        ),
      ),
      body: _driverId == null
          ? Center(child: Text(l10n.pleaseLoginToPlaceOrder))
          : BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const LoadingWidget();
                }

                if (state is OrderError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDriverAndOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrdersLoaded) {
                  // Filter orders by driver ID
                  final driverOrders = state.orders
                      .where((order) => order.driverId == _driverId)
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveOrders(
                        driverOrders
                            .where((o) => o.isActive)
                            .toList(),
                        l10n,
                      ),
                      _buildOrderHistory(
                        driverOrders
                            .where((o) => !o.isActive)
                            .toList(),
                        l10n,
                      ),
                    ],
                  );
                }

                return Center(child: Text(l10n.noOrdersYet));
              },
            ),
    );
  }

  Widget _buildActiveOrders(List<OrderEntity> orders, AppLocalizations l10n) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveOrders,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], l10n, showActions: true);
      },
    );
  }

  Widget _buildOrderHistory(List<OrderEntity> orders, AppLocalizations l10n) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noOrderHistory,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], l10n, showActions: false);
      },
    );
  }

  Widget _buildOrderCard(
    OrderEntity order,
    AppLocalizations l10n, {
    required bool showActions,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/driver/order/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${order.totalAmount.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (showActions && order.status == OrderStatus.ready)
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderCubit>().updateOrderStatus(
                              order.id,
                              OrderStatus.pickedUp,
                            );
                        if (mounted) {
                          context.showSuccessSnackBar('Order picked up');
                        }
                      },
                      child: const Text('Pick Up'),
                    )
                  else if (showActions && order.status == OrderStatus.pickedUp)
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderCubit>().updateOrderStatus(
                              order.id,
                              OrderStatus.delivered,
                            );
                        if (mounted) {
                          context.showSuccessSnackBar('Order delivered');
                        }
                      },
                      child: const Text('Mark Delivered'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
      case OrderStatus.pickedUp:
        return Colors.orange;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

