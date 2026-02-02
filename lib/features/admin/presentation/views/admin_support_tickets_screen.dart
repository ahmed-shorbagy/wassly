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

class AdminSupportTicketsScreen extends StatefulWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  State<AdminSupportTicketsScreen> createState() =>
      _AdminSupportTicketsScreenState();
}

class _AdminSupportTicketsScreenState extends State<AdminSupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportCubit>().loadAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supportChat),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin');
            }
          },
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state is SupportLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SupportError) {
            return Center(child: Text(state.message));
          } else if (state is TicketsLoaded) {
            final tickets = state.tickets;
            if (tickets.isEmpty) {
              return Center(child: Text(l10n.noOrdersFound));
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
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketEntity ticket) {
    final l10n = AppLocalizations.of(context)!;
    final isClosed = ticket.status == TicketStatus.closed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthCubit>().state;
          final userId = authState is AuthAuthenticated
              ? authState.user.id
              : '';

          context.pushNamed(
            'admin-ticket-chat',
            pathParameters: {'ticketId': ticket.id},
            extra: {
              'ticketId': ticket.id,
              'currentUserId': userId,
              'currentUserRole': SenderRole.admin,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isClosed ? Colors.grey : Colors.blue,
                      ),
                    ),
                    child: Text(
                      isClosed ? l10n.closed : l10n.open,
                      style: TextStyle(
                        color: isClosed ? Colors.grey : Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.orderId}: ${ticket.orderNumber}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).add_jm().format(ticket.lastMessageAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
