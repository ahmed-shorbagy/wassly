import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_message_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../models/ticket_model.dart';
import '../models/ticket_message_model.dart';

class SupportRepositoryImpl implements SupportRepository {
  final FirebaseFirestore _firestore;

  SupportRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createTicket(TicketEntity ticket) async {
    final model = TicketModel.fromEntity(ticket);
    await _firestore
        .collection('support_tickets')
        .doc(ticket.id)
        .set(model.toJson());
  }

  @override
  Stream<List<TicketEntity>> getTicketsForCustomer(String customerId) {
    return _firestore
        .collection('support_tickets')
        .where('customerId', isEqualTo: customerId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Stream<List<TicketEntity>> getTicketsForRestaurant(String restaurantId) {
    return _firestore
        .collection('support_tickets')
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Stream<List<TicketEntity>> getTicketsForDriver(String driverId) {
    return _firestore
        .collection('support_tickets')
        .where('driverId', isEqualTo: driverId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Stream<List<TicketEntity>> getTicketsForMarket(String marketId) {
    return _firestore
        .collection('support_tickets')
        .where('marketId', isEqualTo: marketId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Stream<List<TicketEntity>> getAllTickets() {
    return _firestore
        .collection('support_tickets')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Stream<List<TicketMessageEntity>> getMessages(String ticketId) {
    return _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TicketMessageModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Future<void> sendMessage(String ticketId, TicketMessageEntity message) async {
    final model = TicketMessageModel.fromEntity(message);

    final batch = _firestore.batch();

    // Add message
    final messageRef = _firestore
        .collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, model.toJson());

    // Update ticket lastMessageAt
    final ticketRef = _firestore.collection('support_tickets').doc(ticketId);
    batch.update(ticketRef, {
      'lastMessageAt': Timestamp.fromDate(message.createdAt),
    });

    await batch.commit();
  }

  @override
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'status': status.name,
    });
  }
}
