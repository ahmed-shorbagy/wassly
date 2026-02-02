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

// Enum to define which partner type is viewing
enum PartnerSupportType { restaurant, driver, market }

class PartnerSupportScreen extends StatefulWidget {
  final PartnerSupportType supportType;
  final String? partnerId; // Explicit ID if available

  const PartnerSupportScreen({
    super.key,
    required this.supportType,
    this.partnerId,
  });

  @override
  State<PartnerSupportScreen> createState() => _PartnerSupportScreenState();
}

class _PartnerSupportScreenState extends State<PartnerSupportScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    // If partnerId is passed, use it. Otherwise try to get from Auth state.
    // Ideally partnerId is passed from the route.

    if (widget.partnerId != null) {
      _loadByRole(widget.partnerId!);
      return;
    }

    // Fallback using AuthCubit (assumes user.id is the partner id for now)
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _loadByRole(authState.user.id);
    }
  }

  void _loadByRole(String id) {
    final supportCubit = context.read<SupportCubit>();
    switch (widget.supportType) {
      case PartnerSupportType.restaurant:
        supportCubit.loadRestaurantTickets(id);
        break;
      case PartnerSupportType.driver:
        supportCubit.loadDriverTickets(id);
        break;
      case PartnerSupportType.market:
        supportCubit.loadMarketTickets(id);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Handle null l10n gracefully if needed, but for now assuming it loads.

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.supportChat ?? 'Support Chat'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n?.noTicketsFound ?? 'No tickets found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _navigateToCreateTicket(),
                      child: Text(l10n?.reportIssue ?? 'Report Issue'),
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
                return _buildTicketCard(context, ticket, l10n);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTicket(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreateTicket() {
    // Determine route name based on type
    String routeName;
    SenderRole role;

    switch (widget.supportType) {
      case PartnerSupportType.restaurant:
        routeName = 'restaurant-create-ticket';
        role = SenderRole.restaurant;
        break;
      case PartnerSupportType.driver:
        routeName = 'driver-create-ticket';
        role = SenderRole.driver;
        break;
      case PartnerSupportType.market:
        routeName = 'market-create-ticket';
        role = SenderRole
            .market; // Assuming market maps to restaurant for now or needs new role
        break;
    }

    // For market, if SenderRole doesn't have market, we might need to update that enum too.
    // For now assuming existing enum. If 'market' is missing, fallback to restaurant or check enum.

    context.pushNamed(routeName, extra: {'senderRole': role});
  }

  Widget _buildTicketCard(
    BuildContext context,
    TicketEntity ticket,
    AppLocalizations? l10n,
  ) {
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

          // Determine route prefix
          String prefix;
          switch (widget.supportType) {
            case PartnerSupportType.restaurant:
              prefix = 'restaurant';
              break;
            case PartnerSupportType.driver:
              prefix = 'driver';
              break;
            case PartnerSupportType.market:
              prefix = 'market';
              break;
          }

          context.pushNamed(
            '$prefix-ticket-chat',
            pathParameters: {'ticketId': ticket.id},
            extra: {
              'ticketId': ticket.id,
              'currentUserId': userId,
              'currentUserRole': _getSenderRole(),
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
                      isClosed
                          ? (l10n?.closed ?? 'Closed')
                          : (l10n?.open ?? 'Open'),
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
                '${l10n?.orderId ?? 'Order ID'}: ${ticket.orderNumber}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, h:mm a').format(ticket.lastMessageAt),
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

  SenderRole _getSenderRole() {
    switch (widget.supportType) {
      case PartnerSupportType.restaurant:
        return SenderRole.restaurant;
      case PartnerSupportType.driver:
        return SenderRole.driver;
      case PartnerSupportType.market:
        return SenderRole.restaurant; // Fallback or new role
    }
  }
}
