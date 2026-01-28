import '../entities/ticket_entity.dart';
import '../entities/ticket_message_entity.dart';

abstract class SupportRepository {
  Future<void> createTicket(TicketEntity ticket);
  Stream<List<TicketEntity>> getTicketsForCustomer(String customerId);
  Stream<List<TicketEntity>> getTicketsForRestaurant(String restaurantId);
  Stream<List<TicketEntity>> getAllTickets(); // For Admin
  Stream<List<TicketMessageEntity>> getMessages(String ticketId);
  Future<void> sendMessage(String ticketId, TicketMessageEntity message);
  Future<void> updateTicketStatus(String ticketId, TicketStatus status);
}
