import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ticket_message_entity.dart';
import '../cubits/support_cubit.dart';
import '../cubits/support_state.dart';

class CreateTicketScreen extends StatefulWidget {
  final Map<String, dynamic> extras;

  const CreateTicketScreen({super.key, required this.extras});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<SupportCubit>().createTicket(
        orderId: widget.extras['orderId'] ?? '',
        orderNumber: widget.extras['orderNumber'] ?? '',
        customerId: widget.extras['customerId'] ?? '',
        restaurantId: widget.extras['restaurantId'] ?? '',
        subject: _subjectController.text,
        initialMessage: _messageController.text,
        senderRole: widget.extras['senderRole'] ?? SenderRole.customer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.reportIssue ?? 'Report Issue')),
      body: BlocListener<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state is SupportOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.pop();
          } else if (state is SupportError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: l10n?.subject ?? 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n?.fieldRequired ?? 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n?.description ?? 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n?.fieldRequired ?? 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    l10n?.submit ?? 'Submit',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
