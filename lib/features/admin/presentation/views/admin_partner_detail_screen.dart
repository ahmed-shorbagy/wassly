import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/admin_cubit.dart';
import 'image_viewer_screen.dart';

class AdminPartnerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> partner;

  const AdminPartnerDetailScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    final user = partner['user'];
    final details = partner['details'];
    final type = partner['type'];
    final partnerId = partner['id'];
    final userId = user['id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${user['name'] ?? 'Partner'} Details'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child: Icon(
                      type == 'driver'
                          ? Icons.drive_eta
                          : (type == 'restaurant'
                                ? Icons.restaurant
                                : Icons.store),
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type.toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Info
            _buildSectionTitle('Contact Information'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.email,
                      'Email',
                      user['email'] ?? 'N/A',
                    ),
                    const Divider(),
                    _buildDetailRow(
                      Icons.phone,
                      'Phone',
                      user['phone'] ?? 'N/A',
                    ),
                    if (type != 'driver') ...[
                      const Divider(),
                      _buildDetailRow(
                        Icons.location_on,
                        'Address',
                        details['address'] ?? 'N/A',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Documents
            _buildSectionTitle('Documents & Images'),
            if (type == 'driver') ...[
              _buildDocumentGrid(context, [
                _DocItem('Personal Image', details['personalImageUrl']),
                _DocItem('Driver License', details['driverLicenseUrl']),
                _DocItem('Vehicle License', details['vehicleLicenseUrl']),
                _DocItem('Vehicle Photo', details['vehiclePhotoUrl']),
              ]),
            ] else ...[
              _buildDocumentGrid(context, [
                _DocItem(
                  'Commercial Registration',
                  details['commercialRegistrationPhotoUrl'],
                ),
                _DocItem('Logo / Store Image', details['imageUrl']),
                if (details['discountImageUrl'] != null)
                  _DocItem('Discount Image', details['discountImageUrl']),
              ]),
            ],

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _showRejectDialog(context, userId, partnerId, type),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('REJECT REQUEST'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _approvePartner(context, userId, partnerId, type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('APPROVE REQUEST'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid(BuildContext context, List<_DocItem> items) {
    final validItems = items
        .where((item) => item.url != null && item.url!.isNotEmpty)
        .toList();

    if (validItems.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No documents uploaded.')),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: validItems.length,
      itemBuilder: (context, index) {
        final item = validItems[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ImageViewerScreen(imageUrl: item.url!, title: item.label),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.zoom_in, size: 16, color: Colors.purple),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectDialog(
    BuildContext context,
    String userId,
    String partnerId,
    String type,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Partnership?'),
        content: const Text(
          'Are you sure you want to reject this request? This action cannot be undone and will delete the request data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.read<AdminCubit>().rejectPartner(userId, partnerId, type);
              Navigator.pop(context); // Go back to list
              // Note: The list screen's BlocListener will handle the success snackbar
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  void _approvePartner(
    BuildContext context,
    String userId,
    String partnerId,
    String type,
  ) {
    context.read<AdminCubit>().approvePartner(userId, partnerId, type);
    Navigator.pop(context); // Go back to list
  }
}

class _DocItem {
  final String label;
  final String? url;

  _DocItem(this.label, this.url);
}
