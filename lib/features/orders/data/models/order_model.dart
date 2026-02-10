import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    super.imageUrl,
  });

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      productName: entity.productName,
      price: entity.price,
      quantity: entity.quantity,
      imageUrl: entity.imageUrl,
    );
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.customerPhone,
    required super.restaurantId,
    required super.restaurantName,
    super.restaurantImage,
    super.driverId,
    super.driverName,
    super.driverPhone,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.deliveryAddress,
    super.deliveryLocation,
    super.restaurantLocation,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.isPickup,
    super.paymentMethod,
    super.deliveryFee,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      restaurantImage: entity.restaurantImage,
      driverId: entity.driverId,
      driverName: entity.driverName,
      driverPhone: entity.driverPhone,
      items: entity.items,
      totalAmount: entity.totalAmount,
      status: entity.status,
      deliveryAddress: entity.deliveryAddress,
      deliveryLocation: entity.deliveryLocation,
      restaurantLocation: entity.restaurantLocation,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      notes: entity.notes,
      isPickup: entity.isPickup,
      paymentMethod: entity.paymentMethod,
      deliveryFee: entity.deliveryFee,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String,
      customerPhone: data['customerPhone'] as String,
      restaurantId: data['restaurantId'] as String,
      restaurantName: data['restaurantName'] as String,
      restaurantImage: data['restaurantImage'] as String?,
      driverId: data['driverId'] as String?,
      driverName: data['driverName'] as String?,
      driverPhone: data['driverPhone'] as String?,
      items: (data['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      status: _statusFromString(data['status'] as String),
      deliveryAddress: data['deliveryAddress'] as String,
      deliveryLocation: data['deliveryLocation'] as GeoPoint?,
      restaurantLocation: data['restaurantLocation'] as GeoPoint?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      isPickup: data['isPickup'] as bool? ?? false,
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantImage': restaurantImage,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'items': items
          .map((item) => OrderItemModel.fromEntity(item).toJson())
          .toList(),
      'totalAmount': totalAmount,
      'status': _statusToString(status),
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
      'restaurantLocation': restaurantLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
      'isPickup': isPickup,
      'paymentMethod': paymentMethod,
      'deliveryFee': deliveryFee,
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'pickedUp':
        return OrderStatus.pickedUp;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.pickedUp:
        return 'pickedUp';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
