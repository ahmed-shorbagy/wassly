import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ticket_message_entity.dart';
import '../cubits/support_cubit.dart';
import '../cubits/support_state.dart';

class TicketChatScreen extends StatefulWidget {
  final Map<String, dynamic> extras;

  const TicketChatScreen({super.key, required this.extras});

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _ticketId;
  late String _currentUserId;
  late SenderRole _currentUserRole;

  @override
  void initState() {
    super.initState();
    _ticketId = widget.extras['ticketId'];
    _currentUserId = widget.extras['currentUserId'];
    // Default to customer if not provided, can be passed in extras for Admin/Restaurant app
    _currentUserRole = widget.extras['currentUserRole'] ?? SenderRole.customer;

    context.read<SupportCubit>().loadMessages(_ticketId);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    context.read<SupportCubit>().sendMessage(
      ticketId: _ticketId,
      senderId: _currentUserId,
      role: _currentUserRole,
      content: _messageController.text.trim(),
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.supportChat ?? 'Support Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<SupportCubit, SupportState>(
              builder: (context, state) {
                if (state is TicketMessagesLoaded) {
                  final messages = state.messages;
                  // Scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(l10n?.noMessages ?? 'No messages yet'),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderRole == _currentUserRole;
                      return BubbleSpecialThree(
                        text: msg.content,
                        color: isMe ? AppColors.primary : Colors.grey.shade200,
                        tail: true,
                        textStyle: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                        isSender: isMe,
                      );
                    },
                  );
                } else if (state is SupportError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(state.message, textAlign: TextAlign.center),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<SupportCubit>()
                              .loadMessages(_ticketId),
                          child: Text(l10n?.retry ?? 'Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n?.typeMessage ?? 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
