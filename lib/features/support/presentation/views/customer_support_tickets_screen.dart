import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../features/support/domain/entities/ticket_entity.dart';
import '../../../../features/support/domain/entities/ticket_message_entity.dart';
import '../../../../features/support/presentation/cubits/support_cubit.dart';
import '../../../../features/support/presentation/cubits/support_state.dart';

class CustomerSupportTicketsScreen extends StatefulWidget {
  const CustomerSupportTicketsScreen({super.key});

  @override
  State<CustomerSupportTicketsScreen> createState() =>
      _CustomerSupportTicketsScreenState();
}

class _CustomerSupportTicketsScreenState
    extends State<CustomerSupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<SupportCubit>().loadCustomerTickets(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportChat)),
      body: BlocBuilder<SupportCubit, SupportState>(
        buildWhen: (previous, current) => current is! SupportOperationSuccess,
        builder: (context, state) {
          if (state is SupportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SupportError) {
            return Center(child: Text(state.message));
          } else if (state is TicketsLoaded) {
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.noOrdersFound), // "No tickets found" placeholder
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _navigateToCreateTicket(context),
                      child: Text(l10n.reportIssue),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _buildTicketCard(context, ticket);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTicket(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreateTicket(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.pushNamed(
        'customer-create-ticket',
        extra: {
          'customerId': authState.user.id,
          'senderRole': SenderRole.customer,
          // Optional: passing empty order details creates a general ticket
          'orderId': '',
          'orderNumber': 'General',
        },
      );
    }
  }

  Widget _buildTicketCard(BuildContext context, TicketEntity ticket) {
    final l10n = AppLocalizations.of(context)!;
    final isClosed = ticket.status == TicketStatus.closed;

    return Card(
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthCubit>().state;
          final userId = authState is AuthAuthenticated
              ? authState.user.id
              : '';

          context.pushNamed(
            'customer-ticket-chat',
            pathParameters: {'ticketId': ticket.id},
            extra: {
              'ticketId': ticket.id,
              'currentUserId': userId,
              'currentUserRole': SenderRole.customer,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    isClosed ? l10n.closed : l10n.open,
                    style: TextStyle(
                      color: isClosed ? Colors.grey : Colors.blue,
                    ),
                  ),
                ],
              ),
              if (ticket.orderNumber.isNotEmpty &&
                  ticket.orderNumber != 'General')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l10n.orderId}: ${ticket.orderNumber}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d, h:mm a').format(ticket.lastMessageAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
