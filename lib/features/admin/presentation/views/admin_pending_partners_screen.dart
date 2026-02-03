import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions.dart';
import '../cubits/admin_cubit.dart';

class AdminPendingPartnersScreen extends StatefulWidget {
  const AdminPendingPartnersScreen({super.key});

  @override
  State<AdminPendingPartnersScreen> createState() =>
      _AdminPendingPartnersScreenState();
}

class _AdminPendingPartnersScreenState
    extends State<AdminPendingPartnersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().getPendingPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is PartnerApprovedSuccess) {
            context.showSuccessSnackBar('Partner approved successfully!');
          } else if (state is AdminError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingPartnersLoaded) {
            if (state.pendingPartners.isEmpty) {
              return const Center(
                child: Text('No pending partner registrations.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.pendingPartners.length,
              itemBuilder: (context, index) {
                final partner = state.pendingPartners[index];
                final user = partner['user'];
                final details = partner['details'];
                final type = partner['type'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(
                        type == 'driver' ? Icons.drive_eta : Icons.restaurant,
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Text('${user['email']} • ${type.toUpperCase()}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Phone', user['phone'] ?? 'N/A'),
                            if (type == 'driver') ...[
                              _buildInfoRow(
                                'Vehicle',
                                '${details['vehicleType']} - ${details['vehiclePlateNumber']}',
                              ),
                            ] else ...[
                              _buildInfoRow(
                                'Address',
                                details['address'] ?? 'N/A',
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    // Implementation for rejection could be added here
                                    context.showInfoSnackBar(
                                      'Reject functionality not yet implemented',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<AdminCubit>().approvePartner(
                                      user['id'],
                                      partner['id'],
                                      type,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
