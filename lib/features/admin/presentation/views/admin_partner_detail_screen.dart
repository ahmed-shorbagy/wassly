import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/admin_cubit.dart';
import 'image_viewer_screen.dart';

class AdminPartnerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> partner;

  const AdminPartnerDetailScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    final user = partner['user'] ?? {};
    final details = partner['details'] ?? {};
    final type = partner['type'] ?? 'unknown';
    final partnerId = partner['id'] ?? '';
    final userId = user['id'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${user['name'] ?? 'Partner'} Details'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderCard(user, type, details),
            const SizedBox(height: 24),

            // Contact Info
            _buildSectionTitle('Contact Information'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.email_outlined,
                      'Email Address',
                      user['email'] ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.phone_outlined,
                      'Phone Number',
                      user['phone'] ?? 'N/A',
                    ),
                    if (type == 'driver' && details['address'] != null) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.home_outlined,
                        'Home Address',
                        details['address'],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Business/Vehicle Details
            if (type == 'restaurant' || type == 'market') ...[
              _buildSectionTitle('Business Details'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        Icons.description_outlined,
                        'Description',
                        details['description'] ?? 'No description provided.',
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Business Address',
                        details['address'] ?? 'N/A',
                        trailing: details['location'] != null
                            ? TextButton.icon(
                                onPressed: () => _openMap(details['location']),
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: const Text('View on Map'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: Colors.purple,
                                ),
                              )
                            : null,
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              Icons.delivery_dining_outlined,
                              'Delivery Fee',
                              '${details['deliveryFee'] ?? 0} EGP',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailRow(
                              Icons.shopping_basket_outlined,
                              'Min. Order',
                              '${details['minOrderAmount'] ?? 0} EGP',
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        Icons.timer_outlined,
                        'Est. Delivery Time',
                        '${details['estimatedDeliveryTime'] ?? 0} mins',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (type == 'driver') ...[
              _buildSectionTitle('Vehicle Details'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              Icons.directions_car_outlined,
                              'Vehicle Type',
                              (details['vehicleType'] ?? 'N/A')
                                  .toString()
                                  .toUpperCase(),
                            ),
                          ),
                          Expanded(
                            child: _buildDetailRow(
                              Icons.info_outline,
                              'Model',
                              details['vehicleModel'] ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              Icons.palette_outlined,
                              'Color',
                              details['vehicleColor'] ?? 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailRow(
                              Icons.pin_outlined,
                              'Plate Number',
                              details['vehiclePlateNumber'] ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Documents
            _buildSectionTitle('Documents & Verify Images'),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              child: TextButton(
                onPressed: () =>
                    _showRejectDialog(context, userId, partnerId, type),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                child: const Text(
                  'REJECT REQUEST',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'APPROVE REQUEST',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(dynamic user, dynamic type, dynamic details) {
    String? imageUrl;
    if (type == 'driver') {
      imageUrl = details['personalImageUrl'];
    } else {
      imageUrl = details['imageUrl'];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple.withOpacity(0.05),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(
                      type == 'driver'
                          ? Icons.person_outline
                          : (type == 'restaurant'
                                ? Icons.restaurant_outlined
                                : Icons.store_outlined),
                      size: 40,
                      color: Colors.purple,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user['name'] ?? 'No Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _getTypeColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              type.toString().toUpperCase(),
              style: TextStyle(
                color: _getTypeColor(type),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'driver':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'market':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.purple[300]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Future<void> _openMap(dynamic location) async {
    if (location is GeoPoint) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildDocumentGrid(BuildContext context, List<_DocItem> items) {
    final validItems = items
        .where((item) => item.url != null && item.url!.isNotEmpty)
        .toList();

    if (validItems.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No documents uploaded.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
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
        childAspectRatio: 0.85,
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
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
