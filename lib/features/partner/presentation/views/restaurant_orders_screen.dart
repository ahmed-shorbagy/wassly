import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRestaurantAndOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRestaurantAndOrders() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Get restaurant by owner ID
      context.read<RestaurantCubit>().getRestaurantByOwnerId(authState.user.id);
    }
  }

  void _listenToOrders(String restaurantId) {
    context.read<OrderCubit>().listenToRestaurantOrders(restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.restaurantOrders),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.pendingOrders),
            Tab(text: l10n.activeOrders),
            Tab(text: l10n.orderHistory),
          ],
        ),
      ),
      body: BlocConsumer<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantLoaded) {
            setState(() {
              _restaurantId = state.restaurant.id;
            });
            _listenToOrders(state.restaurant.id);
          }
        },
        builder: (context, restaurantState) {
          if (restaurantState is RestaurantLoading) {
            return const LoadingWidget();
          }

          if (restaurantState is RestaurantError) {
            return ErrorDisplayWidget(
              message: restaurantState.message,
              onRetry: _loadRestaurantAndOrders,
            );
          }

          if (_restaurantId == null) {
            return Center(child: Text(l10n.restaurantNotFound));
          }

          return BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              if (orderState is OrderLoading) {
                return const LoadingWidget();
              }

              if (orderState is OrderError) {
                return ErrorDisplayWidget(
                  message: orderState.message,
                  onRetry: () => _listenToOrders(_restaurantId!),
                );
              }

              if (orderState is OrdersLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingOrders(orderState.orders, l10n),
                    _buildActiveOrders(orderState.orders, l10n),
                    _buildOrderHistory(orderState.orders, l10n),
                  ],
                );
              }

              return Center(child: Text(l10n.noOrdersYet));
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingOrders(List<OrderEntity> orders, AppLocalizations l10n) {
    final pendingOrders = orders
        .where((order) => order.status == OrderStatus.pending)
        .toList();

    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions,
        title: l10n.noPendingOrders,
        message: l10n.noPendingOrdersMessage,
        l10n: l10n,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _listenToOrders(_restaurantId!),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(pendingOrders[index], l10n, showActions: true);
        },
      ),
    );
  }

  Widget _buildActiveOrders(List<OrderEntity> orders, AppLocalizations l10n) {
    final activeOrders = orders
        .where(
          (order) =>
              order.status == OrderStatus.accepted ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.ready,
        )
        .toList();

    if (activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant_menu,
        title: l10n.noActiveOrders,
        message: l10n.noActiveOrdersMessage,
        l10n: l10n,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _listenToOrders(_restaurantId!),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(activeOrders[index], l10n, showActions: true);
        },
      ),
    );
  }

  Widget _buildOrderHistory(List<OrderEntity> orders, AppLocalizations l10n) {
    final historyOrders = orders
        .where(
          (order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled,
        )
        .toList();

    if (historyOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: l10n.noOrderHistory,
        message: l10n.noOrderHistoryMessage,
        l10n: l10n,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _listenToOrders(_restaurantId!),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(
            historyOrders[index],
            l10n,
            showActions: false,
          );
        },
      ),
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
        onTap: () => context.push('/restaurant/order/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Order ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.orderId}: #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
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
                  // Status Badge
                  _buildStatusBadge(order.status, l10n),
                ],
              ),

              const Divider(height: 24),

              // Customer Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order.customerPhone,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order Items Preview
              Text(
                l10n.orderItems,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
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
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)?.currencySymbol ?? 'ج.م'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
                    '+ ${order.items.length - 2} ${l10n.moreItems}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.total}: ${order.totalAmount.toStringAsFixed(2)} ${l10n.currencySymbol}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (showActions) _buildActionButtons(order, l10n),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, AppLocalizations l10n) {
    Color backgroundColor;
    IconData icon;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning;
        icon = Icons.pending;
        text = l10n.pending;
        break;
      case OrderStatus.accepted:
        backgroundColor = Colors.blue;
        icon = Icons.check_circle;
        text = l10n.accepted;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.orange;
        icon = Icons.restaurant_menu;
        text = l10n.preparing;
        break;
      case OrderStatus.ready:
        backgroundColor = Colors.green;
        icon = Icons.shopping_bag;
        text = l10n.ready;
        break;
      case OrderStatus.pickedUp:
        backgroundColor = Colors.purple;
        icon = Icons.delivery_dining;
        text = l10n.onTheWay;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        text = l10n.delivered;
        break;
      case OrderStatus.cancelled:
        backgroundColor = AppColors.error;
        icon = Icons.cancel;
        text = l10n.cancelled;
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
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderEntity order, AppLocalizations l10n) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => _rejectOrder(order, l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(l10n.reject),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _acceptOrder(order, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: Text(l10n.accept),
            ),
          ],
        );
      case OrderStatus.accepted:
        return ElevatedButton(
          onPressed: () =>
              _updateOrderStatus(order, OrderStatus.preparing, l10n),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(l10n.startPreparing),
        );
      case OrderStatus.preparing:
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order, OrderStatus.ready, l10n),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: Text(l10n.markAsReady),
        );
      case OrderStatus.ready:
        return Text(
          l10n.waitingForDriver,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _acceptOrder(OrderEntity order, AppLocalizations l10n) async {
    await context.read<OrderCubit>().updateOrderStatus(
      order.id,
      OrderStatus.accepted,
    );
    if (mounted) {
      context.showSuccessSnackBar(l10n.orderAccepted);
    }
  }

  Future<void> _rejectOrder(OrderEntity order, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectOrder),
        content: Text(l10n.rejectOrderConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<OrderCubit>().updateOrderStatus(
        order.id,
        OrderStatus.cancelled,
      );
      if (mounted) {
        context.showSuccessSnackBar(l10n.orderRejected);
      }
    }
  }

  Future<void> _updateOrderStatus(
    OrderEntity order,
    OrderStatus newStatus,
    AppLocalizations l10n,
  ) async {
    await context.read<OrderCubit>().updateOrderStatus(order.id, newStatus);
    if (mounted) {
      context.showSuccessSnackBar(l10n.orderStatusUpdated);
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required AppLocalizations l10n,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
