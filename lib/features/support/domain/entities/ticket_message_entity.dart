import 'package:equatable/equatable.dart';

enum SenderRole { customer, admin, restaurant, driver, market }

class TicketMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final SenderRole senderRole;
  final String content;
  final DateTime createdAt;

  const TicketMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, senderId, senderRole, content, createdAt];
}
