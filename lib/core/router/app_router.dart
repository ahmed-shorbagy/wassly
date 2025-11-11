import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/restaurants/presentation/views/customer_home_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_detail_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_home_screen.dart';
import '../../features/restaurants/presentation/views/driver_home_screen.dart';
import '../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../features/orders/presentation/views/cart_screen.dart';
import '../../features/orders/presentation/views/checkout_screen.dart';
import '../../features/orders/presentation/views/order_list_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
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

      // Customer Routes
      GoRoute(
        path: '/customer',
        name: 'customer',
        builder: (context, state) => const CustomerHomeScreen(),
        routes: [
          GoRoute(
            path: 'restaurants',
            name: 'customer-restaurants',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: 'restaurant/:id',
            name: 'customer-restaurant-detail',
            builder: (context, state) {
              final restaurantId = state.pathParameters['id'] ?? '';
              return RestaurantDetailScreen(restaurantId: restaurantId);
            },
          ),
          GoRoute(
            path: 'cart',
            name: 'customer-cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'checkout',
            name: 'customer-checkout',
            builder: (context, state) {
              final restaurantId = state.uri.queryParameters['restaurantId'] ?? '';
              // Get restaurant from cubit or pass as extra
              final restaurant = state.extra;
              if (restaurant != null) {
                return CheckoutScreen(restaurant: restaurant as dynamic);
              }
              // Fallback: fetch restaurant by ID
              return FutureBuilder(
                future: _getRestaurant(context, restaurantId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasData) {
                    return CheckoutScreen(restaurant: snapshot.data as dynamic);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Restaurant not found')),
                  );
                },
              );
            },
          ),
          GoRoute(
            path: 'orders',
            name: 'customer-orders',
            builder: (context, state) => const OrderListScreen(),
          ),
          GoRoute(
            path: 'order/:id',
            name: 'customer-order-detail',
            builder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return OrderDetailScreen(orderId: orderId);
            },
          ),
          GoRoute(
            path: 'profile',
            name: 'customer-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
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
            path: 'products',
            name: 'restaurant-products',
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: 'product/add',
            name: 'restaurant-add-product',
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: 'product/edit/:id',
            name: 'restaurant-edit-product',
            builder: (context, state) {
              final productId = state.pathParameters['id'] ?? '';
              return EditProductScreen(productId: productId);
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

// Placeholder screens - these will be implemented in the respective feature modules

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }
}

class RestaurantOrdersScreen extends StatelessWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Restaurant Orders Screen')),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Product List Screen')));
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Add Product Screen')));
  }
}

class EditProductScreen extends StatelessWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Edit Product Screen - ID: $productId')),
    );
  }
}

class RestaurantSettingsScreen extends StatelessWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Restaurant Settings Screen')),
    );
  }
}

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Driver Orders Screen')));
  }
}

class DriverOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const DriverOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Driver Order Detail Screen - ID: $orderId')),
    );
  }
}

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Driver Profile Screen')));
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error Screen')));
  }
}

// Helper function to get restaurant
Future<dynamic> _getRestaurant(BuildContext context, String restaurantId) async {
  // This is a workaround - in production, you'd want to handle this better
  final cubit = context.read<RestaurantCubit>();
  await cubit.getRestaurantById(restaurantId);
  final state = cubit.state;
  if (state is RestaurantLoaded) {
    return state.restaurant;
  }
  return null;
}
