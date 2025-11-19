import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubits/order_cubit.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<OrderEntity> _allOrders = [];
  List<OrderEntity> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_filterOrders);
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllOrders() {
    context.read<OrderCubit>().getAllOrders();
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = List.from(_allOrders);
      } else {
        _filteredOrders = _allOrders.where((order) {
          final orderIdMatch = order.id.toLowerCase().contains(query);
          final customerMatch = order.customerName.toLowerCase().contains(query);
          final restaurantMatch = order.restaurantName.toLowerCase().contains(query);
          final phoneMatch = order.customerPhone.toLowerCase().contains(query);
          return orderIdMatch || customerMatch || restaurantMatch || phoneMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/admin');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Management'),
          backgroundColor: Colors.purple,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              const Tab(text: 'All Orders'),
              Tab(text: l10n.pendingOrders),
              Tab(text: l10n.activeOrders),
              Tab(text: l10n.orderHistory),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllOrders,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) => TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                    _filterOrders();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _filterOrders();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Orders List
            Expanded(
              child: BlocConsumer<OrderCubit, OrderState>(
                listener: (context, state) {
                  if (state is OrdersLoaded) {
                    setState(() {
                      _allOrders = state.orders;
                      _filteredOrders = state.orders;
                    });
                    _filterOrders();
                  } else if (state is OrderError) {
                    context.showErrorSnackBar(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading && _allOrders.isEmpty) {
                    return const LoadingWidget();
                  }

                  if (state is OrderError && _allOrders.isEmpty) {
                    return ErrorDisplayWidget(
                      message: state.message,
                      onRetry: _loadAllOrders,
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(_filteredOrders),
                      _buildOrdersList(
                        _filteredOrders
                            .where((o) => o.status == OrderStatus.pending)
                            .toList(),
                      ),
                      _buildOrdersList(
                        _filteredOrders
                            .where((o) => o.isActive)
                            .toList(),
                      ),
                      _buildOrdersList(
                        _filteredOrders
                            .where((o) => !o.isActive)
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAllOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to order detail
          context.push('/admin/orders/${order.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Restaurant Image
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
                  // Order Info
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
                  // Status Badge
                  _buildStatusBadge(order.status),
                ],
              ),
              const Divider(height: 24),
              // Customer Info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 14),
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
              const SizedBox(height: 8),
              // Items Count
              Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Total
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
                  TextButton(
                    onPressed: () {
                      context.push('/admin/orders/${order.id}');
                    },
                    child: const Text('View Details'),
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
            status.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

