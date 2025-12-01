import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/partner_splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_home_screen.dart';
import '../../features/restaurants/presentation/views/driver_home_screen.dart';
import '../../features/partner/presentation/views/restaurant_orders_screen.dart';
import '../../features/partner/presentation/views/restaurant_settings_screen.dart';
import '../../features/partner/presentation/views/product_management_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';
import '../../features/drivers/presentation/views/driver_orders_screen.dart';
import '../../features/auth/presentation/views/customer_profile_screen.dart';

class PartnerRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const PartnerSplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Restaurant Routes
      GoRoute(
        path: '/restaurant',
        name: 'restaurant',
        builder: (context, state) => const RestaurantHomeScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            name: 'restaurant-orders',
            builder: (context, state) => const RestaurantOrdersScreen(),
          ),
          GoRoute(
            path: 'order/:id',
            name: 'restaurant-order-detail',
            builder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return RestaurantOrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'products',
            name: 'restaurant-products',
            builder: (context, state) {
              // Restaurant ID will be fetched from auth state in the screen
              return const RestaurantProductsScreen();
            },
          ),
          GoRoute(
            path: 'settings',
            name: 'restaurant-settings',
            builder: (context, state) => const RestaurantSettingsScreen(),
          ),
        ],
      ),

      // Driver Routes
      GoRoute(
        path: '/driver',
        name: 'driver',
        builder: (context, state) => const DriverHomeScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            name: 'driver-orders',
            builder: (context, state) => const DriverOrdersScreen(),
          ),
          GoRoute(
            path: 'order/:id',
            name: 'driver-order-detail',
            builder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return DriverOrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'profile',
            name: 'driver-profile',
            builder: (context, state) => const DriverProfileScreen(),
          ),
        ],
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

class RestaurantOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const RestaurantOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return OrderDetailScreen(orderId: orderId);
  }
}

class DriverOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const DriverOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return OrderDetailScreen(orderId: orderId);
  }
}

class RestaurantProductsScreen extends StatelessWidget {
  const RestaurantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductManagementScreen();
  }
}

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use customer profile screen for driver profile
    return const CustomerProfileScreen();
  }
}

