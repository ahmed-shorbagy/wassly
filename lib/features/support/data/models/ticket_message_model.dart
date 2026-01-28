import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_message_entity.dart';

class TicketMessageModel extends TicketMessageEntity {
  const TicketMessageModel({
    required super.id,
    required super.senderId,
    required super.senderRole,
    required super.content,
    required super.createdAt,
  });

  factory TicketMessageModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TicketMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderRole: _roleFromString(data['senderRole']),
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderRole': senderRole.name,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static SenderRole _roleFromString(String? role) {
    return SenderRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => SenderRole.customer,
    );
  }

  factory TicketMessageModel.fromEntity(TicketMessageEntity entity) {
    return TicketMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      senderRole: entity.senderRole,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}
