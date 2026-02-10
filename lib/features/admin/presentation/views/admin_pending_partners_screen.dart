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
                                'Address',
                                details['address'] ?? 'N/A',
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (type == 'driver') ...[
                              _buildDocumentSection(
                                context,
                                'Driver Documents',
                                [
                                  _DocItem(
                                    'Personal Image',
                                    details['personalImageUrl'],
                                  ),
                                  _DocItem(
                                    'Driver License',
                                    details['driverLicenseUrl'],
                                  ),
                                  _DocItem(
                                    'Vehicle License',
                                    details['vehicleLicenseUrl'],
                                  ),
                                  _DocItem(
                                    'Vehicle Photo',
                                    details['vehiclePhotoUrl'],
                                  ),
                                ],
                              ),
                            ] else ...[
                              _buildDocumentSection(
                                context,
                                'Business Documents',
                                [
                                  _DocItem(
                                    'Commercial Registration',
                                    details['commercialRegistrationPhotoUrl'],
                                  ),
                                  _DocItem('Logo', details['imageUrl']),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Reject Partner?'),
                                        content: const Text(
                                          'Are you sure you want to reject and delete this registration request?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              context
                                                  .read<AdminCubit>()
                                                  .rejectPartner(
                                                    user['id'],
                                                    partner['id'],
                                                    type,
                                                  );
                                            },
                                            child: const Text(
                                              'Reject',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

  Widget _buildDocumentSection(
    BuildContext context,
    String title,
    List<_DocItem> items,
  ) {
    // Filter out items with null URLs
    final validItems = items.where((item) => item.url != null).toList();

    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: validItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = validItems[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _showImageDialog(context, item.label, item.url!),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 80,
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 200,
                child: Center(child: Icon(Icons.error, size: 48)),
              ),
            ),
          ],
        ),
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

class _DocItem {
  final String label;
  final String? url;

  _DocItem(this.label, this.url);
}
