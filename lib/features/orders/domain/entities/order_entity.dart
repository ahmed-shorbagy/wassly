import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  pickedUp,
  delivered,
  cancelled,
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props =>
      [productId, productName, price, quantity, imageUrl];
}

class OrderEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImage;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final GeoPoint? deliveryLocation;
  final GeoPoint? restaurantLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImage,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.deliveryLocation,
    this.restaurantLocation,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  // Helper methods
  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.accepted;

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerPhone,
        restaurantId,
        restaurantName,
        restaurantImage,
        driverId,
        driverName,
        driverPhone,
        items,
        totalAmount,
        status,
        deliveryAddress,
        deliveryLocation,
        restaurantLocation,
        createdAt,
        updatedAt,
        notes,
      ];
}

