import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  /// Create a new order
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);

  /// Get order by ID
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Get all orders for a customer
  Future<Either<Failure, List<OrderEntity>>> getCustomerOrders(
    String customerId,
  );

  /// Get active orders for a customer
  Future<Either<Failure, List<OrderEntity>>> getActiveOrders(String customerId);

  /// Get order history for a customer
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory(String customerId);

  /// Cancel an order
  Future<Either<Failure, void>> cancelOrder(String orderId);

  /// Listen to order updates (real-time)
  Stream<OrderEntity> listenToOrder(String orderId);

  /// Listen to customer's active orders (real-time)
  Stream<List<OrderEntity>> listenToCustomerOrders(String customerId);

  /// Get all orders for a restaurant
  Future<Either<Failure, List<OrderEntity>>> getRestaurantOrders(
    String restaurantId,
  );

  /// Get all orders (admin only)
  Future<Either<Failure, List<OrderEntity>>> getAllOrders();

  /// Listen to all orders in real-time (admin only)
  Stream<List<OrderEntity>> listenToAllOrders();

  /// Listen to restaurant orders (real-time)
  Stream<List<OrderEntity>> listenToRestaurantOrders(String restaurantId);

  /// Update order status
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );

  /// Assign driver to order
  Future<Either<Failure, void>> assignDriverToOrder(
    String orderId,
    String driverId,
    String driverName,
    String driverPhone,
  );

  /// Get orders for a driver
  Future<Either<Failure, List<OrderEntity>>> getDriverOrders(
    List<String> driverIds,
  );

  /// Get available orders for drivers (ready to be picked up)
  Future<Either<Failure, List<OrderEntity>>> getAvailableOrdersForDrivers();

  /// Listen to driver orders (real-time)
  Stream<List<OrderEntity>> listenToDriverOrders(List<String> driverIds);

  /// Listen to available orders (real-time) - for drivers to pick up
  Stream<List<OrderEntity>> listenToAvailableOrders();
}
