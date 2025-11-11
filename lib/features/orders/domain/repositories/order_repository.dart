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
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory(
    String customerId,
  );

  /// Cancel an order
  Future<Either<Failure, void>> cancelOrder(String orderId);

  /// Listen to order updates (real-time)
  Stream<OrderEntity> listenToOrder(String orderId);

  /// Listen to customer's active orders (real-time)
  Stream<List<OrderEntity>> listenToCustomerOrders(String customerId);
}

