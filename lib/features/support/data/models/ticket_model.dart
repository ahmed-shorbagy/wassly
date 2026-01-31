import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.orderId,
    required super.orderNumber,
    required super.customerId,
    required super.restaurantId,
    super.driverId,
    super.marketId,
    required super.status,
    required super.subject,
    required super.createdAt,
    required super.lastMessageAt,
  });

  factory TicketModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      customerId: data['customerId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      driverId: data['driverId'],
      marketId: data['marketId'],
      status: _statusFromString(data['status']),
      subject: data['subject'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'driverId': driverId,
      'marketId': marketId,
      'status': status.name,
      'subject': subject,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }

  static TicketStatus _statusFromString(String? status) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TicketStatus.open,
    );
  }

  factory TicketModel.fromEntity(TicketEntity entity) {
    return TicketModel(
      id: entity.id,
      orderId: entity.orderId,
      orderNumber: entity.orderNumber,
      customerId: entity.customerId,
      restaurantId: entity.restaurantId,
      driverId: entity.driverId,
      marketId: entity.marketId,
      status: entity.status,
      subject: entity.subject,
      createdAt: entity.createdAt,
      lastMessageAt: entity.lastMessageAt,
    );
  }
}
