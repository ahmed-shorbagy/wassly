import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .snapshots(),
        builder: (context, ordersSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .snapshots(),
            builder: (context, restaurantsSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, usersSnapshot) {
                  final ordersCount = ordersSnapshot.data?.docs.length ?? 0;
                  final restaurantsCount =
                      restaurantsSnapshot.data?.docs.length ?? 0;
                  final usersCount = usersSnapshot.data?.docs.length ?? 0;

                  // Calculate total revenue
                  double totalRevenue = 0;
                  if (ordersSnapshot.hasData) {
                    for (var doc in ordersSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final total = (data['totalAmount'] ?? 0.0) as num;
                      totalRevenue += total.toDouble();
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              'Total Orders',
                              ordersCount.toString(),
                              Icons.receipt_long,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Total Restaurants',
                              restaurantsCount.toString(),
                              Icons.restaurant,
                              Colors.orange,
                            ),
                            _buildStatCard(
                              'Total Users',
                              usersCount.toString(),
                              Icons.people,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Total Revenue',
                              '${totalRevenue.toStringAsFixed(2)} ر.س',
                              Icons.attach_money,
                              Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Recent orders
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Orders',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (ordersSnapshot.hasData &&
                                    ordersSnapshot.data!.docs.isNotEmpty)
                                  ...ordersSnapshot.data!.docs.take(5).map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        data['restaurantName'] ?? 'Unknown',
                                      ),
                                      subtitle: Text(
                                        '${data['totalAmount'] ?? 0.0} ر.س',
                                      ),
                                      trailing: Text(
                                        data['status'] ?? 'pending',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  })
                                else
                                  const Text('No recent orders'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

