import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_customer_orders_usecase.dart';
import '../../domain/usecases/get_active_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/repositories/order_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/entities/wallet_transaction.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetCustomerOrdersUseCase getCustomerOrdersUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final OrderRepository repository;
  final WalletRepository walletRepository;

  StreamSubscription? _orderSubscription;
  StreamSubscription? _ordersListSubscription;
  StreamSubscription? _availableOrdersSubscription;
  StreamSubscription? _driverOrdersSubscription;
  StreamSubscription? _restaurantOrdersSubscription;

  OrderCubit({
    required this.createOrderUseCase,
    required this.getCustomerOrdersUseCase,
    required this.getActiveOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.cancelOrderUseCase,
    required this.repository,
    required this.walletRepository,
  }) : super(OrderInitial());

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    _ordersListSubscription?.cancel();
    _availableOrdersSubscription?.cancel();
    _driverOrdersSubscription?.cancel();
    _restaurantOrdersSubscription?.cancel();
    return super.close();
  }

  /// Create a new order
  Future<void> createOrder(OrderEntity order) async {
    try {
      emit(OrderCreating());
      AppLogger.logInfo('Creating order for customer: ${order.customerId}');

      final result = await createOrderUseCase(order);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to create order', error: failure.message);
          emit(OrderError(failure.message));
        },
        (createdOrder) {
          AppLogger.logSuccess('Order created: ${createdOrder.id}');
          emit(OrderCreated(createdOrder));
        },
      );
    } catch (e) {
      AppLogger.logError('Error creating order', error: e);
      emit(const OrderError('Failed to create order'));
    }
  }

  /// Get all orders for a customer
  Future<void> getCustomerOrders(String customerId) async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching orders for customer: $customerId');

      final result = await getCustomerOrdersUseCase(customerId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to fetch orders', error: failure.message);
          emit(OrderError(failure.message));
        },
        (orders) {
          AppLogger.logSuccess('Fetched ${orders.length} orders');
          emit(OrdersLoaded(orders));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching orders', error: e);
      emit(const OrderError('Failed to fetch orders'));
    }
  }

  /// Get active orders for a customer
  Future<void> getActiveOrders(String customerId) async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching active orders for customer: $customerId');

      final result = await getActiveOrdersUseCase(customerId);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch active orders',
            error: failure.message,
          );
          emit(OrderError(failure.message));
        },
        (orders) {
          AppLogger.logSuccess('Fetched ${orders.length} active orders');
          emit(OrdersLoaded(orders));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching active orders', error: e);
      emit(const OrderError('Failed to fetch active orders'));
    }
  }

  /// Get order by ID
  Future<void> getOrderById(String orderId) async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching order: $orderId');

      final result = await getOrderByIdUseCase(orderId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to fetch order', error: failure.message);
          emit(OrderError(failure.message));
        },
        (order) {
          AppLogger.logSuccess('Order fetched: $orderId');
          emit(OrderLoaded(order));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching order', error: e);
      emit(const OrderError('Failed to fetch order'));
    }
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      emit(OrderCancelling());
      AppLogger.logInfo('Cancelling order: $orderId');

      final result = await cancelOrderUseCase(orderId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to cancel order', error: failure.message);
          emit(OrderError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Order cancelled: $orderId');
          emit(OrderCancelled());
        },
      );
    } catch (e) {
      AppLogger.logError('Error cancelling order', error: e);
      emit(const OrderError('Failed to cancel order'));
    }
  }

  /// Listen to order updates in real-time
  void listenToOrder(String orderId) {
    try {
      AppLogger.logInfo('Setting up real-time listener for order: $orderId');

      _orderSubscription?.cancel();
      _orderSubscription = repository
          .listenToOrder(orderId)
          .listen(
            (order) {
              AppLogger.logInfo(
                'Order updated: ${order.id} - ${order.statusText}',
              );
              emit(OrderLoaded(order));
            },
            onError: (error) {
              AppLogger.logError('Error in order stream', error: error);
              emit(const OrderError('Failed to get order updates'));
            },
          );
    } catch (e) {
      AppLogger.logError('Error setting up order listener', error: e);
      emit(const OrderError('Failed to listen to order updates'));
    }
  }

  /// Listen to customer orders in real-time
  void listenToCustomerOrders(String customerId) {
    try {
      AppLogger.logInfo(
        'Setting up real-time listener for customer orders: $customerId',
      );

      _ordersListSubscription?.cancel();
      _ordersListSubscription = repository
          .listenToCustomerOrders(customerId)
          .listen(
            (orders) {
              AppLogger.logInfo(
                'Customer orders updated: ${orders.length} orders',
              );
              emit(OrdersLoaded(orders));
            },
            onError: (error) {
              AppLogger.logError('Error in orders stream', error: error);
              emit(const OrderError('Failed to get orders updates'));
            },
          );
    } catch (e) {
      AppLogger.logError('Error setting up orders listener', error: e);
      emit(const OrderError('Failed to listen to orders updates'));
    }
  }

  /// Get all orders (admin only)
  Future<void> getAllOrders() async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching all orders (admin)');

      final result = await repository.getAllOrders();

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch all orders',
            error: failure.message,
          );
          emit(OrderError(failure.message));
        },
        (orders) {
          AppLogger.logSuccess('Fetched ${orders.length} orders');
          emit(OrdersLoaded(orders));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching all orders', error: e);
      emit(const OrderError('Failed to fetch all orders'));
    }
  }

  /// Listen to all orders in real-time (admin only)
  void listenToAllOrders() {
    try {
      AppLogger.logInfo('Setting up real-time listener for all orders (admin)');

      _ordersListSubscription?.cancel();
      _ordersListSubscription = repository.listenToAllOrders().listen(
        (orders) {
          AppLogger.logInfo('All orders updated: ${orders.length} orders');
          emit(OrdersLoaded(orders));
        },
        onError: (error) {
          AppLogger.logError('Error in all orders stream', error: error);
          emit(const OrderError('Failed to get orders updates'));
        },
      );
    } catch (e) {
      AppLogger.logError('Error setting up all orders listener', error: e);
      emit(const OrderError('Failed to listen to orders updates'));
    }
  }

  /// Listen to restaurant orders in real-time
  void listenToRestaurantOrders(String restaurantId) {
    try {
      AppLogger.logInfo(
        'Setting up real-time listener for restaurant orders: $restaurantId',
      );

      _restaurantOrdersSubscription?.cancel();
      _restaurantOrdersSubscription = repository
          .listenToRestaurantOrders(restaurantId)
          .listen(
            (orders) {
              AppLogger.logInfo(
                'Restaurant orders updated: ${orders.length} orders',
              );
              emit(OrdersLoaded(orders));
            },
            onError: (error) {
              AppLogger.logError(
                'Error in restaurant orders stream',
                error: error,
              );
              emit(const OrderError('Failed to get orders updates'));
            },
          );
    } catch (e) {
      AppLogger.logError(
        'Error setting up restaurant orders listener',
        error: e,
      );
      emit(const OrderError('Failed to listen to orders updates'));
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      emit(OrderUpdating());
      AppLogger.logInfo('Updating order status: $orderId to $status');

      final result = await repository.updateOrderStatus(orderId, status);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to update order', error: failure.message);
          emit(OrderError(failure.message));
        },
        (_) async {
          AppLogger.logSuccess('Order status updated successfully');
          emit(OrderUpdated());

          // If order is delivered, create wallet transaction
          if (status == OrderStatus.delivered) {
            final orderResult = await repository.getOrderById(orderId);
            orderResult.fold(
              (_) {}, // Ignore error fetching order for transaction
              (order) async {
                if (order.driverId != null) {
                  // 1. Credit Transaction (Earnings - Delivery Fee)
                  final creditTransaction = WalletTransaction(
                    id: DateTime.now().millisecondsSinceEpoch
                        .toString(), // Simple ID generation
                    driverId: order.driverId!,
                    amount: order.deliveryFee,
                    type: TransactionType.credit,
                    description:
                        'Delivery Fee - Order #${order.id.substring(0, 6)}',
                    date: DateTime.now(),
                    orderId: order.id,
                  );
                  await walletRepository.addTransaction(creditTransaction);

                  // 2. Debit Transaction (Cash Collected) - Only if Cash on Delivery
                  if (order.paymentMethod == 'cash') {
                    final debitTransaction = WalletTransaction(
                      id: '${DateTime.now().millisecondsSinceEpoch}_debit',
                      driverId: order.driverId!,
                      amount: order.totalAmount,
                      type: TransactionType.debit,
                      description:
                          'Cash collected - Order #${order.id.substring(0, 6)}',
                      date: DateTime.now(),
                      orderId: order.id,
                    );
                    await walletRepository.addTransaction(debitTransaction);
                  }
                }
              },
            );
          }

          // Reload order to get updated state
          getOrderById(orderId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating order status', error: e);
      emit(const OrderError('Failed to update order status'));
    }
  }

  /// Assign driver to order
  Future<void> assignDriverToOrder(
    String orderId,
    String driverId,
    String driverName,
    String driverPhone,
  ) async {
    try {
      emit(OrderUpdating());
      AppLogger.logInfo('Assigning driver to order: $orderId');

      final result = await repository.assignDriverToOrder(
        orderId,
        driverId,
        driverName,
        driverPhone,
      );

      result.fold(
        (failure) {
          AppLogger.logError('Failed to assign driver', error: failure.message);
          emit(OrderError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Driver assigned successfully');
          emit(OrderUpdated());
          getOrderById(orderId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error assigning driver', error: e);
      emit(const OrderError('Failed to assign driver'));
    }
  }

  /// Get orders for a driver
  Future<void> getDriverOrders(List<String> driverIds) async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching orders for driver IDs: $driverIds');

      final result = await repository.getDriverOrders(driverIds);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch driver orders',
            error: failure.message,
          );
          emit(OrderError(failure.message));
        },
        (orders) {
          AppLogger.logSuccess('Fetched ${orders.length} driver orders');
          emit(DriverOrdersLoaded(orders));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching driver orders', error: e);
      emit(const OrderError('Failed to fetch driver orders'));
    }
  }

  /// Get available orders for drivers
  Future<void> getAvailableOrdersForDrivers() async {
    try {
      emit(OrderLoading());
      AppLogger.logInfo('Fetching available orders for drivers');

      final result = await repository.getAvailableOrdersForDrivers();

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch available orders',
            error: failure.message,
          );
          emit(OrderError(failure.message));
        },
        (orders) {
          AppLogger.logSuccess('Fetched ${orders.length} available orders');
          emit(AvailableOrdersLoaded(orders));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching available orders', error: e);
      emit(const OrderError('Failed to fetch available orders'));
    }
  }

  /// Listen to driver orders in real-time
  void listenToDriverOrders(List<String> driverIds) {
    try {
      AppLogger.logInfo(
        'Setting up real-time listener for driver orders with IDs: $driverIds',
      );

      _driverOrdersSubscription?.cancel();
      _driverOrdersSubscription = repository
          .listenToDriverOrders(driverIds)
          .listen(
            (orders) {
              AppLogger.logInfo(
                'Driver orders updated: ${orders.length} orders',
              );
              emit(DriverOrdersLoaded(orders));
            },
            onError: (error) {
              AppLogger.logError('Error in driver orders stream', error: error);
              emit(const OrderError('Failed to get orders updates'));
            },
          );
    } catch (e) {
      AppLogger.logError('Error setting up driver orders listener', error: e);
      emit(const OrderError('Failed to listen to orders updates'));
    }
  }

  /// Listen to available orders in real-time (for drivers)
  void listenToAvailableOrders() {
    try {
      AppLogger.logInfo('Setting up real-time listener for available orders');

      _availableOrdersSubscription?.cancel();
      _availableOrdersSubscription = repository
          .listenToAvailableOrders()
          .listen(
            (orders) {
              AppLogger.logInfo(
                'Available orders updated: ${orders.length} orders',
              );
              emit(AvailableOrdersLoaded(orders));
            },
            onError: (error) {
              AppLogger.logError(
                'Error in available orders stream',
                error: error,
              );
              emit(const OrderError('Failed to get orders updates'));
            },
          );
    } catch (e) {
      AppLogger.logError(
        'Error setting up available orders listener',
        error: e,
      );
      emit(const OrderError('Failed to listen to orders updates'));
    }
  }

  void cancelOrdersSubscription() {
    _ordersListSubscription?.cancel();
    _ordersListSubscription = null;
    _availableOrdersSubscription?.cancel();
    _availableOrdersSubscription = null;
    _driverOrdersSubscription?.cancel();
    _driverOrdersSubscription = null;
    _restaurantOrdersSubscription?.cancel();
    _restaurantOrdersSubscription = null;
    emit(OrderInitial());
  }
}
