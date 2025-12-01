import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../domain/entities/order_entity.dart';
import '../cubits/order_cubit.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Listen to real-time updates for active orders
      context.read<OrderCubit>().listenToCustomerOrders(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n?.myOrders ?? 'طلباتي');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: AppLocalizations.of(context)?.activeOrders ?? 'Active'),
            Tab(text: AppLocalizations.of(context)?.orderHistory ?? 'History'),
          ],
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const LoadingWidget();
          }

          if (state is OrderError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadOrders,
            );
          }

          if (state is OrdersLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildActiveOrders(state.orders),
                _buildOrderHistory(),
              ],
            );
          }

          final l10n = AppLocalizations.of(context);
          return Center(
            child: Text(l10n?.noOrdersYet ?? 'لا توجد طلبات حتى الآن'),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrders(List<OrderEntity> orders) {
    final activeOrders = orders.where((order) => order.isActive).toList();

    if (activeOrders.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _buildEmptyState(
        icon: Icons.receipt_long,
        title: l10n?.noActiveOrders ?? 'No Active Orders',
        message: l10n?.noActiveOrdersMessage ?? 'You don\'t have any active orders',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(activeOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderHistory() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          final l10n = AppLocalizations.of(context);
          return Center(child: Text(l10n?.pleaseLogIn ?? 'يرجى تسجيل الدخول'));
        }

        return FutureBuilder<void>(
          future: _loadOrderHistory(authState.user.id),
          builder: (context, snapshot) {
            return BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                if (orderState is OrderLoading) {
                  return const LoadingWidget();
                }

                if (orderState is OrdersLoaded) {
                  final completedOrders = orderState.orders
                      .where((order) => !order.isActive)
                      .toList();

                  if (completedOrders.isEmpty) {
                    final l10n = AppLocalizations.of(context);
                    return _buildEmptyState(
                      icon: Icons.history,
                      title: l10n?.noOrderHistory ?? 'No Order History',
                      message: l10n?.noOrderHistoryMessage ?? 'Your completed orders will appear here',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadOrderHistory(authState.user.id),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: completedOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(completedOrders[index]);
                      },
                    ),
                  );
                }

                final l10n = AppLocalizations.of(context);
                return Center(
                  child: Text(l10n?.noOrdersFound ?? 'لم يتم العثور على طلبات'),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _loadOrderHistory(String customerId) async {
    await context.read<OrderCubit>().getCustomerOrders(customerId);
  }

  Widget _buildOrderCard(OrderEntity order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/order/${order.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Restaurant and status
              Row(
                children: [
                  // Restaurant image
                  if (order.restaurantImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: order.restaurantImage!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.surface,
                          child: const Icon(Icons.restaurant),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant),
                    ),
                  const SizedBox(width: 12),

                  // Restaurant name and date
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
                          DateFormat(
                            'MMM dd, yyyy • HH:mm',
                          ).format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  _buildStatusBadge(order.status),
                ],
              ),

              const Divider(height: 24),

              // Items
              ...order.items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AppLocalizations.of(context)?.moreItems(order.items.length - 2) ??
                        '+ ${order.items.length - 2} more items',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Total and view button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppLocalizations.of(context)?.total ?? 'Total'}: ${order.totalAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)?.currencySymbol ?? 'ج.م'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/order/${order.id}'),
                    child: Text(
                      AppLocalizations.of(context)?.viewDetails ??
                          'عرض التفاصيل',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color backgroundColor;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning;
        icon = Icons.pending;
        break;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
        backgroundColor = Colors.blue;
        icon = Icons.restaurant;
        break;
      case OrderStatus.ready:
      case OrderStatus.pickedUp:
        backgroundColor = Colors.orange;
        icon = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppColors.error;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case OrderStatus.pending:
        return l10n?.orderPending ?? 'Pending';
      case OrderStatus.accepted:
        return l10n?.orderAccepted ?? 'Accepted';
      case OrderStatus.preparing:
        return l10n?.orderPreparing ?? 'Preparing';
      case OrderStatus.ready:
        return l10n?.orderReady ?? 'Ready';
      case OrderStatus.pickedUp:
        return l10n?.orderPickedUp ?? 'On the Way';
      case OrderStatus.delivered:
        return l10n?.orderDelivered ?? 'Delivered';
      case OrderStatus.cancelled:
        return l10n?.orderCancelled ?? 'Cancelled';
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push('/home'),
            child: Text(
              AppLocalizations.of(context)?.browseRestaurants ?? 'تصفح المطاعم',
            ),
          ),
        ],
      ),
    );
  }
}
