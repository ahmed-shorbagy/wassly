import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/restaurants/presentation/views/customer_home_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_detail_screen.dart';
import '../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../features/orders/presentation/views/cart_screen.dart';
import '../../features/orders/presentation/views/checkout_screen.dart';
import '../../features/orders/presentation/views/order_list_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';

class CustomerRouter {
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
        path: '/home',
        name: 'home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        name: 'restaurant-detail',
        builder: (context, state) {
          final restaurantId = state.pathParameters['id'] ?? '';
          return RestaurantDetailScreen(restaurantId: restaurantId);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) {
          final restaurant = state.extra;
          if (restaurant != null) {
            return CheckoutScreen(restaurant: restaurant as dynamic);
          }
          return const Scaffold(
            body: Center(child: Text('Restaurant not found')),
          );
        },
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Page Not Found')),
    );
  }
}

