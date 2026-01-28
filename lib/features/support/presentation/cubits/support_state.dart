import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_message_entity.dart';

abstract class SupportState extends Equatable {
  const SupportState();

  @override
  List<Object?> get props => [];
}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportOperationSuccess extends SupportState {
  final String message;
  const SupportOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class SupportError extends SupportState {
  final String message;
  const SupportError(this.message);
  @override
  List<Object?> get props => [message];
}

class TicketsLoaded extends SupportState {
  final List<TicketEntity> tickets;
  const TicketsLoaded(this.tickets);
  @override
  List<Object?> get props => [tickets];
}

class TicketMessagesLoaded extends SupportState {
  final List<TicketMessageEntity> messages;
  const TicketMessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}
