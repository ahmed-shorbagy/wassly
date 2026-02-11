import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/driver_cubit.dart';
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DriverCubit, DriverState>(
      builder: (context, driverState) {
        final driverIds = <String>[];
        if (driverState is DriverLoaded) {
          driverIds.add(driverState.driver.id);
          driverIds.add(driverState.driver.userId);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: Text(l10n.navOrders),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: l10n.activeOrders),
                Tab(text: l10n.orderHistory),
              ],
            ),
          ),
          body: driverIds.isEmpty
              ? Center(child: Text(l10n.pleaseLoginToPlaceOrder))
              : BlocBuilder<OrderCubit, OrderState>(
                  buildWhen: (previous, current) =>
                      current is DriverOrdersLoaded ||
                      current is OrdersLoaded ||
                      current is OrderLoading ||
                      current is OrderError,
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
                              onPressed: () {
                                if (driverIds.isNotEmpty) {
                                  context
                                      .read<OrderCubit>()
                                      .listenToDriverOrders(driverIds);
                                }
                              },
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DriverOrdersLoaded) {
                      final driverOrders = state.orders;

                      if (driverOrders.isEmpty) {
                        return Center(child: Text(l10n.noOrdersYet));
                      }

                      final activeOrders = driverOrders
                          .where((o) => o.isActive)
                          .toList();
                      final historyOrders = driverOrders
                          .where((o) => !o.isActive)
                          .toList();

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildActiveOrders(activeOrders, l10n),
                          _buildOrderHistory(historyOrders, l10n),
                        ],
                      );
                    }

                    // If initial or other state, load orders again if we have the ID
                    if (driverIds.isNotEmpty) {
                      context.read<OrderCubit>().listenToDriverOrders(
                        driverIds,
                      );
                    }

                    return const Center(child: LoadingWidget());
                  },
                ),
        );
      },
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
              color: AppColors.textSecondary.withOpacity(0.5),
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
              color: AppColors.textSecondary.withOpacity(0.5),
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
                          l10n.orderNumber(
                            order.id.substring(0, 8).toUpperCase(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                    l10n.totalAmountLabel(
                      '${order.totalAmount.toStringAsFixed(2)} ${l10n.currencySymbol}',
                    ),
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
                          context.showSuccessSnackBar(
                            l10n.orderPickedUpSuccess,
                          );
                        }
                      },
                      child: Text(l10n.pickUp),
                    )
                  else if (showActions && order.status == OrderStatus.pickedUp)
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderCubit>().updateOrderStatus(
                          order.id,
                          OrderStatus.delivered,
                        );
                        if (mounted) {
                          context.showSuccessSnackBar(
                            l10n.orderDeliveredSuccess,
                          );
                        }
                      },
                      child: Text(l10n.markDelivered),
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
