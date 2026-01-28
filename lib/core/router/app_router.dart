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
import '../../features/partner/presentation/views/product_management_screen.dart';
import '../../features/admin/presentation/views/admin_add_product_screen.dart';
import '../../features/admin/presentation/views/admin_edit_product_screen.dart';
import '../../features/auth/presentation/views/customer_profile_screen.dart';
import '../../features/support/presentation/views/customer_support_tickets_screen.dart';
import '../../features/support/presentation/views/ticket_chat_screen.dart';
import '../../features/support/presentation/views/create_ticket_screen.dart';
import '../../features/partner/presentation/views/restaurant_orders_screen.dart';
import '../../features/partner/presentation/views/restaurant_settings_screen.dart';
import '../../features/drivers/presentation/views/driver_orders_screen.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';

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
              final restaurantId =
                  state.uri.queryParameters['restaurantId'] ?? '';
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
            builder: (context, state) => const CustomerProfileScreen(),
          ),
          GoRoute(
            path: 'support',
            name: 'customer-support',
            builder: (context, state) => const CustomerSupportTicketsScreen(),
            routes: [
              GoRoute(
                path: 'chat/:ticketId',
                name: 'customer-ticket-chat',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>;
                  return TicketChatScreen(extras: extras);
                },
              ),
              GoRoute(
                path: 'create',
                name: 'customer-create-ticket',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>;
                  return CreateTicketScreen(extras: extras);
                },
              ),
            ],
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
              return const ProductManagementScreen();
            },
          ),
          GoRoute(
            path: 'products/add',
            name: 'restaurant-add-product',
            builder: (context, state) {
              // Get restaurant ID from auth state
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                // Get restaurant by owner ID
                return FutureBuilder(
                  future: _getRestaurantByOwnerId(context, authState.user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final restaurant = snapshot.data as dynamic;
                      return AdminAddProductScreen(restaurantId: restaurant.id);
                    }
                    return const Scaffold(
                      body: Center(child: Text('Restaurant not found')),
                    );
                  },
                );
              }
              return const Scaffold(body: Center(child: Text('Please login')));
            },
          ),
          GoRoute(
            path: 'products/edit/:id',
            name: 'restaurant-edit-product',
            builder: (context, state) {
              final productId = state.pathParameters['id'] ?? '';
              // Get restaurant ID from auth state
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                return FutureBuilder(
                  future: _getRestaurantByOwnerId(context, authState.user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final restaurant = snapshot.data as dynamic;
                      return AdminEditProductScreen(
                        restaurantId: restaurant.id,
                        productId: productId,
                      );
                    }
                    return const Scaffold(
                      body: Center(child: Text('Restaurant not found')),
                    );
                  },
                );
              }
              return const Scaffold(body: Center(child: Text('Please login')));
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
            builder: (context, state) => const CustomerProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

// Restaurant Order Detail Screen
class RestaurantOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const RestaurantOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Use the same order detail screen but with restaurant-specific actions
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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error Screen')));
  }
}

// Helper function to get restaurant
Future<dynamic> _getRestaurant(
  BuildContext context,
  String restaurantId,
) async {
  final cubit = context.read<RestaurantCubit>();
  await cubit.getRestaurantById(restaurantId);
  final state = cubit.state;
  if (state is RestaurantLoaded) {
    return state.restaurant;
  }
  return null;
}

// Helper function to get restaurant by owner ID
Future<dynamic> _getRestaurantByOwnerId(
  BuildContext context,
  String ownerId,
) async {
  final cubit = context.read<RestaurantCubit>();
  await cubit.getRestaurantByOwnerId(ownerId);
  final state = cubit.state;
  if (state is RestaurantLoaded) {
    return state.restaurant;
  }
  return null;
}
