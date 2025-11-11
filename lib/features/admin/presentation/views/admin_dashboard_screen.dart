import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Admin Access'),
                  content: const Text(
                    'You have full administrative access to all platform features.\n\n'
                    'No authentication required.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Info',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              title: 'Restaurants',
              icon: Icons.restaurant,
              color: Colors.orange,
              count: '0',
              onTap: () => context.go('/admin/restaurants'),
            ),
            _buildDashboardCard(
              context,
              title: 'Drivers',
              icon: Icons.delivery_dining,
              color: Colors.blue,
              count: '0',
              onTap: () => context.go('/admin/drivers'),
            ),
            _buildDashboardCard(
              context,
              title: 'Users',
              icon: Icons.people,
              color: Colors.green,
              count: '0',
              onTap: () => context.go('/admin/users'),
            ),
            _buildDashboardCard(
              context,
              title: 'Analytics',
              icon: Icons.analytics,
              color: Colors.purple,
              count: '📊',
              onTap: () => context.go('/admin/analytics'),
            ),
            _buildDashboardCard(
              context,
              title: 'Orders',
              icon: Icons.shopping_bag,
              color: Colors.red,
              count: '0',
              onTap: () => context.go('/admin/orders'),
            ),
            _buildDashboardCard(
              context,
              title: 'Settings',
              icon: Icons.settings,
              color: Colors.grey,
              count: '⚙️',
              onTap: () => context.go('/admin/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String count,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

