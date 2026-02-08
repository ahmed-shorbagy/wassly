import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

import '../../../../core/services/notification_sender_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore firestore;
  final NotificationSenderService notificationSenderService;

  OrderRepositoryImpl({
    required this.firestore,
    required this.notificationSenderService,
  });

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    try {
      AppLogger.logInfo('Creating order for customer: ${order.customerId}');

      final orderModel = OrderModel.fromEntity(order);
      final docRef = await firestore
          .collection('orders')
          .add(orderModel.toFirestore());

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

      // Send Notifications (Client-side trigger)
      // 1. To Restaurant
      await notificationSenderService.sendNotificationToTopic(
        topic: 'restaurant_${order.restaurantId}',
        title: 'New Order Received! 🔔',
        body: 'Order #${docRef.id.substring(0, 8)} has been placed.',
        data: {'orderId': docRef.id},
      );

      // 2. To Admin
      await notificationSenderService.sendNotificationToTopic(
        topic: 'admin_notifications',
        title: 'New Order Alert 🚨',
        body: 'New order placed at ${order.restaurantName}.',
        data: {'orderId': docRef.id},
      );

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
          .where(
            'status',
            whereIn: ['pending', 'accepted', 'preparing', 'ready', 'pickedUp'],
          )
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
        .where(
          'status',
          whereIn: ['pending', 'accepted', 'preparing', 'ready', 'pickedUp'],
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      AppLogger.logInfo('Fetching all orders (admin)');

      final snapshot = await firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} orders');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching all orders', error: e);
      return Left(ServerFailure('Failed to fetch orders: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching all orders', error: e);
      return Left(ServerFailure('Failed to fetch orders'));
    }
  }

  @override
  Stream<List<OrderEntity>> listenToAllOrders() {
    AppLogger.logInfo('Setting up real-time listener for all orders (admin)');

    return firestore
        .collection('orders')
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

      // Send Notification to Customer
      try {
        // 1. Fetch Order to get Customer ID
        final orderDoc = await firestore
            .collection('orders')
            .doc(orderId)
            .get();
        if (orderDoc.exists) {
          final customerId = orderDoc.data()?['customerId'] as String?;
          if (customerId != null) {
            // 2. Fetch Customer User Doc to get Token
            final userDoc = await firestore
                .collection('users')
                .doc(customerId)
                .get();
            final fcmToken = userDoc.data()?['fcmToken'] as String?;

            if (fcmToken != null) {
              // 3. Send Notification
              String title = 'Order Update';
              String body = 'Your order status is now ${status.name}';

              if (status == OrderStatus.accepted) {
                title = 'Order Accepted! ✅';
                body = 'The restaurant has accepted your order.';
              } else if (status == OrderStatus.preparing) {
                title = 'Order Preparing 🍳';
                body = 'Your food is being prepared.';
              } else if (status == OrderStatus.ready) {
                title = 'Order Ready 🥡';
                body = 'Your order is ready for pickup/delivery.';
              } else if (status == OrderStatus.pickedUp) {
                title = 'Order Picked Up 🛵';
                body = 'Your order is on the way!';
              } else if (status == OrderStatus.delivered) {
                title = 'Order Delivered 🍽️';
                body = 'Enjoy your meal!';
              }

              await notificationSenderService.sendNotificationToToken(
                token: fcmToken,
                title: title,
                body: body,
                data: {'orderId': orderId},
              );
            }
          }
        }
      } catch (e) {
        AppLogger.logError(
          'Failed to send status update notification',
          error: e,
        );
        // Don't fail the usecase just because notification failed
      }

      // Send Notification to Drivers (When order is Ready)
      if (status == OrderStatus.ready) {
        try {
          await notificationSenderService.sendNotificationToTopic(
            topic: 'drivers', // Or a more specific topic like 'drivers_city'
            title: 'New Order Available! 📦',
            body: 'A new order is ready for pickup.',
            data: {'orderId': orderId},
          );
        } catch (e) {
          AppLogger.logError('Failed to send driver notification', error: e);
        }
      }

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
        // Status remains as is (likely 'ready' or 'accepted'), driver must pick it up manually
        // 'status': 'pickedUp',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify Restaurant that driver is assigned
      try {
        final orderDoc = await firestore
            .collection('orders')
            .doc(orderId)
            .get();
        if (orderDoc.exists) {
          final restaurantId = orderDoc.data()?['restaurantId'] as String?;
          if (restaurantId != null) {
            await notificationSenderService.sendNotificationToTopic(
              topic: 'restaurant_$restaurantId',
              title: 'Driver Assigned 🚚',
              body: '$driverName will pick up the order.',
              data: {'orderId': orderId, 'driverId': driverId},
            );
          }
        }
      } catch (e) {
        AppLogger.logError(
          'Failed to send driver assigned notification',
          error: e,
        );
      }

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

  @override
  Future<Either<Failure, List<OrderEntity>>> getDriverOrders(
    String driverId,
  ) async {
    try {
      AppLogger.logInfo('Fetching orders for driver: $driverId');

      final snapshot = await firestore
          .collection('orders')
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} orders for driver');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching driver orders', error: e);
      return Left(ServerFailure('Failed to fetch orders: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching driver orders', error: e);
      return Left(ServerFailure('Failed to fetch orders'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>>
  getAvailableOrdersForDrivers() async {
    try {
      AppLogger.logInfo('Fetching available orders for drivers');

      final snapshot = await firestore
          .collection('orders')
          .where('status', isEqualTo: 'ready')
          .where('driverId', isNull: true)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc);
      }).toList();

      AppLogger.logSuccess('Fetched ${orders.length} available orders');
      return Right(orders);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching available orders', error: e);
      return Left(
        ServerFailure('Failed to fetch available orders: ${e.message}'),
      );
    } catch (e) {
      AppLogger.logError('Error fetching available orders', error: e);
      return Left(ServerFailure('Failed to fetch available orders'));
    }
  }

  @override
  Stream<List<OrderEntity>> listenToDriverOrders(String driverId) {
    AppLogger.logInfo('Setting up real-time listener for driver orders');

    return firestore
        .collection('orders')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromFirestore(doc);
          }).toList();
        });
  }

  @override
  Stream<List<OrderEntity>> listenToAvailableOrders() {
    AppLogger.logInfo('Setting up real-time listener for available orders');

    return firestore
        .collection('orders')
        .where('status', isEqualTo: 'ready')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // Filter out orders that already have a driver assigned
          return snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .where(
                (order) => order.driverId == null || order.driverId!.isEmpty,
              )
              .toList();
        });
  }
}
