import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/admin/presentation/views/admin_splash_screen.dart';
import '../../features/admin/presentation/views/admin_dashboard_screen.dart';
import '../../features/admin/presentation/views/restaurant_management_screen.dart';
import '../../features/admin/presentation/views/create_restaurant_screen.dart';

class AdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Admin Splash Screen (No Authentication Required)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const AdminSplashScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/restaurants',
        name: 'restaurants',
        builder: (context, state) => const RestaurantManagementScreen(),
      ),
      GoRoute(
        path: '/admin/restaurants/create',
        name: 'create-restaurant',
        builder: (context, state) => const CreateRestaurantScreen(),
      ),
      GoRoute(
        path: '/admin/restaurants/edit/:id',
        name: 'edit-restaurant',
        builder: (context, state) {
          final restaurantId = state.pathParameters['id'] ?? '';
          final restaurant = state.extra;
          return EditRestaurantScreen(
            restaurantId: restaurantId,
            restaurant: restaurant,
          );
        },
      ),
      GoRoute(
        path: '/admin/drivers',
        name: 'drivers',
        builder: (context, state) => const DriverManagementScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        name: 'orders',
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

// Placeholder screens
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Page Not Found')));
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(child: Text('Analytics - Coming Soon')),
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(child: Text('User Management - Coming Soon')),
    );
  }
}

class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Management'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(child: Text('Driver Management - Coming Soon')),
    );
  }
}

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(child: Text('Order Management - Coming Soon')),
    );
  }
}

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(child: Text('Settings - Coming Soon')),
    );
  }
}

class EditRestaurantScreen extends StatelessWidget {
  final String restaurantId;
  final dynamic restaurant;

  const EditRestaurantScreen({
    super.key,
    required this.restaurantId,
    this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Restaurant'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text('Edit Restaurant Screen - ID: $restaurantId'),
      ),
    );
  }
}

