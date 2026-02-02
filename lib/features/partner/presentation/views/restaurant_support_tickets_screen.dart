import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../../../features/support/domain/entities/ticket_entity.dart';
import '../../../../features/support/domain/entities/ticket_message_entity.dart';
import '../../../../features/support/presentation/cubits/support_cubit.dart';
import '../../../../features/support/presentation/cubits/support_state.dart';

class RestaurantSupportTicketsScreen extends StatefulWidget {
  const RestaurantSupportTicketsScreen({super.key});

  @override
  State<RestaurantSupportTicketsScreen> createState() =>
      _RestaurantSupportTicketsScreenState();
}

class _RestaurantSupportTicketsScreenState
    extends State<RestaurantSupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // We need the restaurant ID.
      // Assuming RestaurantCubit has the current restaurant loaded or we fetch it by user ID
      // Or checking if the user metadata has restaurant info.
      // Safest way:
      final restaurantState = context.read<RestaurantCubit>().state;
      if (restaurantState is RestaurantLoaded) {
        context.read<SupportCubit>().loadRestaurantTickets(
          restaurantState.restaurant.id,
        );
      } else {
        // Try to load restaurant by owner id first
        context.read<RestaurantCubit>().getRestaurantByOwnerId(
          authState.user.id,
        );
      }
    }
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
          onPressed: () => context.pop(),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocListener<RestaurantCubit, RestaurantState>(
        listener: (context, state) {
          if (state is RestaurantLoaded) {
            context.read<SupportCubit>().loadRestaurantTickets(
              state.restaurant.id,
            );
          }
        },
        child: BlocBuilder<SupportCubit, SupportState>(
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
                      Text(l10n.noTicketsFound),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.pushNamed('restaurant-create-ticket'),
                        child: Text(l10n.reportIssue),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return _buildTicketCard(context, ticket);
                },
              );
            } else {
              // Initial state or if we are waiting for RestaurantCubit to load
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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
            'restaurant-ticket-chat',
            pathParameters: {'ticketId': ticket.id},
            extra: {
              'ticketId': ticket.id,
              'currentUserId': userId,
              'currentUserRole': SenderRole.restaurant,
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
                  // Date formatting
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
}
