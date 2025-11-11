import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/order_entity.dart';
import '../cubits/order_cubit.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to real-time order updates
    context.read<OrderCubit>().listenToOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrderLoaded && state.order.canBeCancelled) {
                return IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: () => _showCancelDialog(context, state.order),
                  tooltip: 'Cancel Order',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelled) {
            context.showSuccessSnackBar('Order cancelled successfully');
            context.pop();
          } else if (state is OrderError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const LoadingWidget();
          }

          if (state is OrderError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<OrderCubit>().listenToOrder(widget.orderId);
              },
            );
          }

          if (state is OrderLoaded) {
            return _buildOrderDetails(context, state.order);
          }

          return const Center(child: Text('Loading order...'));
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Timeline
          _buildStatusTimeline(order),

          const Divider(height: 1),

          // Restaurant Info
          _buildRestaurantInfo(order),

          const Divider(height: 1),

          // Order Items
          _buildOrderItems(order),

          const Divider(height: 1),

          // Delivery Info
          _buildDeliveryInfo(order),

          const Divider(height: 1),

          // Order Summary
          _buildOrderSummary(order),

          // Driver Info (if assigned)
          if (order.driverId != null) ...[
            const Divider(height: 1),
            _buildDriverInfo(order),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          // Current Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getStatusIcon(order.status),
              const SizedBox(width: 12),
              Text(
                order.statusText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Progress
          _buildStatusProgress(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(OrderStatus currentStatus) {
    final statuses = [
      (OrderStatus.pending, 'Order Placed', Icons.receipt),
      (OrderStatus.accepted, 'Accepted', Icons.check_circle_outline),
      (OrderStatus.preparing, 'Preparing', Icons.restaurant_menu),
      (OrderStatus.ready, 'Ready', Icons.shopping_bag),
      (OrderStatus.pickedUp, 'On the Way', Icons.delivery_dining),
      (OrderStatus.delivered, 'Delivered', Icons.done_all),
    ];

    final currentIndex = statuses.indexWhere((s) => s.$1 == currentStatus);

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final (status, label, icon) = entry.value;
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isActive && index < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Status label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRestaurantInfo(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Restaurant image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: order.restaurantImage != null
                ? CachedNetworkImage(
                    imageUrl: order.restaurantImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.surface,
                      child: const Icon(Icons.restaurant),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.surface,
                    child: const Icon(Icons.restaurant),
                  ),
          ),
          const SizedBox(width: 16),

          // Restaurant details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Restaurant',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.restaurantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item image
                    if (item.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 50,
                            height: 50,
                            color: AppColors.surface,
                            child: const Icon(Icons.fastfood, size: 20),
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
                        child: const Icon(Icons.fastfood, size: 20),
                      ),
                    const SizedBox(width: 12),

                    // Item details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity}x \$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item total
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.phone, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerPhone,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.notes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order ID', style: TextStyle(fontSize: 14)),
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Time', style: TextStyle(fontSize: 14)),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(order.createdAt),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(OrderEntity order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driver Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.driverName ?? 'Driver',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.driverPhone != null)
                      Text(
                        order.driverPhone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (order.driverPhone != null)
                IconButton(
                  onPressed: () {
                    // TODO: Call driver
                    context.showSuccessSnackBar('Calling ${order.driverName}...');
                  },
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Icon _getStatusIcon(OrderStatus status) {
    IconData iconData;
    switch (status) {
      case OrderStatus.pending:
        iconData = Icons.pending;
        break;
      case OrderStatus.accepted:
        iconData = Icons.check_circle;
        break;
      case OrderStatus.preparing:
        iconData = Icons.restaurant_menu;
        break;
      case OrderStatus.ready:
        iconData = Icons.shopping_bag;
        break;
      case OrderStatus.pickedUp:
        iconData = Icons.delivery_dining;
        break;
      case OrderStatus.delivered:
        iconData = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        iconData = Icons.cancel;
        break;
    }
    return Icon(iconData, size: 32, color: AppColors.primary);
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<OrderCubit>().cancelOrder(order.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

