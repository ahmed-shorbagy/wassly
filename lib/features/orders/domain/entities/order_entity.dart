import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/restaurants/domain/entities/product_options.dart';

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
  final List<ProductOption> selectedOptions;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.selectedOptions = const [],
  });

  double get totalPrice {
    final optionsPrice = selectedOptions.fold(
      0.0,
      (sum, option) => sum + option.priceModifier,
    );
    return (price + optionsPrice) * quantity;
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    price,
    quantity,
    imageUrl,
    selectedOptions,
  ];
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
  final bool isPickup;
  final String paymentMethod;
  final double deliveryFee;

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
    this.isPickup = false,
    this.paymentMethod = 'cash',
    this.deliveryFee = 0.0,
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
    isPickup,
    paymentMethod,
    deliveryFee,
  ];
}
