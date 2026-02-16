import 'package:flutter/material.dart';

class PartnerRequestCard extends StatelessWidget {
  final Map<String, dynamic> partner;
  final VoidCallback onTap;

  const PartnerRequestCard({
    super.key,
    required this.partner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = partner['user'];
    final type = partner['type'];

    // Determine icon based on type
    IconData typeIcon;
    Color typeColor;
    String typeLabel;

    if (type == 'driver') {
      typeIcon = Icons.drive_eta;
      typeColor = Colors.blue;
      typeLabel = 'Driver';
    } else if (type == 'restaurant') {
      typeIcon = Icons.restaurant;
      typeColor = Colors.orange;
      typeLabel = 'Restaurant';
    } else {
      typeIcon = Icons.store;
      typeColor = Colors.green;
      typeLabel = 'Market';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar / Icon
              CircleAvatar(
                radius: 28,
                backgroundColor: typeColor.withOpacity(0.1),
                child: Icon(typeIcon, color: typeColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? 'No Email',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
