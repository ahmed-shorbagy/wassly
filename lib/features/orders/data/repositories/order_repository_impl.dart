import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore firestore;

  OrderRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      AppLogger.logInfo('Creating order for customer: ${order.customerId}');

      final orderModel = OrderModel.fromEntity(order);
      final docRef = await firestore.collection('orders').add(
            orderModel.toFirestore(),
          );

      final createdOrder = OrderModel(
        id: docRef.id,
        customerId: order.customerId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        restaurantId: order.restaurantId,
        restaurantName: order.restaurantName,
        restaurantImage: order.restaurantImage,
        driverId: order.driverId,
        driverName: order.driverName,
        driverPhone: order.driverPhone,
        items: order.items,
        totalAmount: order.totalAmount,
        status: order.status,
        deliveryAddress: order.deliveryAddress,
        deliveryLocation: order.deliveryLocation,
        restaurantLocation: order.restaurantLocation,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
        notes: order.notes,
      );

      AppLogger.logSuccess('Order created successfully: ${docRef.id}');
      return Right(createdOrder);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error creating order', error: e);
      return Left(ServerFailure('Failed to create order: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error creating order', error: e);
      return Left(ServerFailure('Failed to create order'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      AppLogger.logInfo('Fetching order: $orderId');

      final doc = await firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        AppLogger.logWarning('Order not found: $orderId');
        return Left(CacheFailure('Order not found'));
      }

      final order = OrderModel.fromFirestore(doc);
      AppLogger.logSuccess('Order fetched successfully: $orderId');
      return Right(order);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching order', error: e);
      return Left(ServerFailure('Failed to fetch order: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching order', error: e);
      return Left(ServerFailure('Failed to fetch order'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getCustomerOrders(
    String customerId,
  ) async {
    try {
      AppLogger.logInfo('Fetching all orders for customer: $customerId');

      final snapshot = await firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} orders for customer');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching customer orders', error: e);
      return Left(ServerFailure('Failed to fetch orders: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching customer orders', error: e);
      return Left(ServerFailure('Failed to fetch orders'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getActiveOrders(
    String customerId,
  ) async {
    try {
      AppLogger.logInfo('Fetching active orders for customer: $customerId');

      final snapshot = await firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .where('status', whereIn: [
            'pending',
            'accepted',
            'preparing',
            'ready',
            'pickedUp',
          ])
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} active orders');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching active orders', error: e);
      return Left(ServerFailure('Failed to fetch active orders: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching active orders', error: e);
      return Left(ServerFailure('Failed to fetch active orders'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrderHistory(
    String customerId,
  ) async {
    try {
      AppLogger.logInfo('Fetching order history for customer: $customerId');

      final snapshot = await firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .where('status', whereIn: ['delivered', 'cancelled'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} past orders');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching order history', error: e);
      return Left(ServerFailure('Failed to fetch order history: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching order history', error: e);
      return Left(ServerFailure('Failed to fetch order history'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      AppLogger.logInfo('Cancelling order: $orderId');

      await firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logSuccess('Order cancelled successfully: $orderId');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error cancelling order', error: e);
      return Left(ServerFailure('Failed to cancel order: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error cancelling order', error: e);
      return Left(ServerFailure('Failed to cancel order'));
    }
  }

  @override
  Stream<OrderEntity> listenToOrder(String orderId) {
    AppLogger.logInfo('Setting up real-time listener for order: $orderId');

    return firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) {
        throw ServerException('Order not found');
      }
      return OrderModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<OrderEntity>> listenToCustomerOrders(String customerId) {
    AppLogger.logInfo('Setting up real-time listener for customer orders');

    return firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: [
          'pending',
          'accepted',
          'preparing',
          'ready',
          'pickedUp',
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getRestaurantOrders(
    String restaurantId,
  ) async {
    try {
      AppLogger.logInfo('Fetching orders for restaurant: $restaurantId');

      final snapshot = await firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} orders for restaurant');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching restaurant orders', error: e);
      return Left(ServerFailure('Failed to fetch orders: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching restaurant orders', error: e);
      return Left(ServerFailure('Failed to fetch orders'));
    }
  }

  @override
  Stream<List<OrderEntity>> listenToRestaurantOrders(String restaurantId) {
    AppLogger.logInfo('Setting up real-time listener for restaurant orders');

    return firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      AppLogger.logInfo('Updating order status: $orderId to $status');

      await firestore.collection('orders').doc(orderId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logSuccess('Order status updated successfully');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating order status', error: e);
      return Left(ServerFailure('Failed to update order: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating order status', error: e);
      return Left(ServerFailure('Failed to update order'));
    }
  }

  @override
  Future<Either<Failure, void>> assignDriverToOrder(
    String orderId,
    String driverId,
    String driverName,
    String driverPhone,
  ) async {
    try {
      AppLogger.logInfo('Assigning driver to order: $orderId');

      await firestore.collection('orders').doc(orderId).update({
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': 'pickedUp',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logSuccess('Driver assigned successfully');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error assigning driver', error: e);
      return Left(ServerFailure('Failed to assign driver: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error assigning driver', error: e);
      return Left(ServerFailure('Failed to assign driver'));
    }
  }
}

