import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_message_entity.dart';
import '../../domain/repositories/support_repository.dart';
import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository _repository;

  StreamSubscription? _ticketsSubscription;
  StreamSubscription? _messagesSubscription;

  SupportCubit(this._repository) : super(SupportInitial());

  @override
  Future<void> close() {
    _ticketsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }

  // Create Ticket
  Future<void> createTicket({
    required String orderId,
    required String orderNumber,
    required String customerId,
    required String restaurantId,
    required String subject,
    required String initialMessage,
    SenderRole senderRole = SenderRole.customer,
  }) async {
    try {
      emit(SupportLoading());

      final ticketId = const Uuid().v4();
      final now = DateTime.now();

      final ticket = TicketEntity(
        id: ticketId,
        orderId: orderId,
        orderNumber: orderNumber,
        customerId: customerId,
        restaurantId: restaurantId,
        status: TicketStatus.open,
        subject: subject,
        createdAt: now,
        lastMessageAt: now,
      );

      // Create ticket
      await _repository.createTicket(ticket);

      // Send initial message
      final messageId = const Uuid().v4();
      final message = TicketMessageEntity(
        id: messageId,
        senderId: senderRole == SenderRole.customer ? customerId : restaurantId,
        senderRole: senderRole,
        content: initialMessage,
        createdAt: now,
      );

      await _repository.sendMessage(ticketId, message);

      emit(const SupportOperationSuccess('Ticket created successfully'));
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }

  // Load Customer Tickets
  void loadCustomerTickets(String customerId) {
    emit(SupportLoading());
    _ticketsSubscription?.cancel();
    _ticketsSubscription = _repository
        .getTicketsForCustomer(customerId)
        .listen(
          (tickets) => emit(TicketsLoaded(tickets)),
          onError: (e) => emit(SupportError(e.toString())),
        );
  }

  // Load Request Tickets (for later use)
  void loadRestaurantTickets(String restaurantId) {
    emit(SupportLoading());
    _ticketsSubscription?.cancel();
    _ticketsSubscription = _repository
        .getTicketsForRestaurant(restaurantId)
        .listen(
          (tickets) => emit(TicketsLoaded(tickets)),
          onError: (e) => emit(SupportError(e.toString())),
        );
  }

  // Load Admin Tickets (for later use)
  void loadAllTickets() {
    emit(SupportLoading());
    _ticketsSubscription?.cancel();
    _ticketsSubscription = _repository.getAllTickets().listen(
      (tickets) => emit(TicketsLoaded(tickets)),
      onError: (e) => emit(SupportError(e.toString())),
    );
  }

  // Load Messages for a specific Ticket
  void loadMessages(String ticketId) {
    emit(SupportLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository
        .getMessages(ticketId)
        .listen(
          (messages) => emit(TicketMessagesLoaded(messages)),
          onError: (e) => emit(SupportError(e.toString())),
        );
  }

  // Send Message
  Future<void> sendMessage({
    required String ticketId,
    required String senderId,
    required SenderRole role,
    required String content,
  }) async {
    try {
      final messageId = const Uuid().v4();
      final message = TicketMessageEntity(
        id: messageId,
        senderId: senderId,
        senderRole: role,
        content: content,
        createdAt: DateTime.now(),
      );

      await _repository.sendMessage(ticketId, message);
      // No emit needed as we are listening to stream
    } catch (e) {
      emit(SupportError(e.toString()));
    }
  }
}
