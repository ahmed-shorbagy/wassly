import 'package:equatable/equatable.dart';

enum TicketStatus { open, resolved, closed }

class TicketEntity extends Equatable {
  final String id;
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String restaurantId;
  final TicketStatus status;
  final String subject;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  const TicketEntity({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.restaurantId,
    required this.status,
    required this.subject,
    required this.createdAt,
    required this.lastMessageAt,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    orderNumber,
    customerId,
    restaurantId,
    status,
    subject,
    createdAt,
    lastMessageAt,
  ];
}
