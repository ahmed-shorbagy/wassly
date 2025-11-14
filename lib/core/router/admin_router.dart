import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/admin/presentation/views/admin_splash_screen.dart';
import '../../features/admin/presentation/views/admin_dashboard_screen.dart';
import '../../features/admin/presentation/views/restaurant_management_screen.dart';
import '../../features/admin/presentation/views/create_restaurant_screen.dart';
import '../../features/admin/presentation/views/admin_product_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_product_screen.dart';
import '../../features/admin/presentation/views/edit_restaurant_screen.dart';
import '../../features/restaurants/domain/entities/restaurant_entity.dart';

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
          final restaurant = state.extra is RestaurantEntity
              ? state.extra as RestaurantEntity
              : null;
          return EditRestaurantScreen(
            restaurantId: restaurantId,
            restaurant: restaurant,
          );
        },
      ),
      // Product Management Routes
      GoRoute(
        path: '/admin/restaurants/:restaurantId/products',
        name: 'admin-restaurant-products',
        builder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId'] ?? '';
          final restaurant = state.extra as Map<String, dynamic>?;
          return AdminProductListScreen(
            restaurantId: restaurantId,
            restaurantName: restaurant?['name'] ?? 'Restaurant',
          );
        },
      ),
      GoRoute(
        path: '/admin/restaurants/:restaurantId/products/add',
        name: 'admin-add-product',
        builder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId'] ?? '';
          return AdminAddProductScreen(restaurantId: restaurantId);
        },
      ),
      GoRoute(
        path: '/admin/restaurants/:restaurantId/products/edit/:productId',
        name: 'admin-edit-product',
        builder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId'] ?? '';
          final productId = state.pathParameters['productId'] ?? '';
          final product = state.extra;
          return AdminEditProductScreen(
            restaurantId: restaurantId,
            productId: productId,
            product: product,
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

class AdminEditProductScreen extends StatelessWidget {
  final String restaurantId;
  final String productId;
  final dynamic product;

  const AdminEditProductScreen({
    super.key,
    required this.restaurantId,
    required this.productId,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.purple,
      ),
      body: Center(child: Text('Edit Product Screen - ID: $productId')),
    );
  }
}
