import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/partner_splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/partner_signup_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_home_screen.dart';
import '../../features/drivers/presentation/views/driver_home_screen.dart';
import '../../features/partner/presentation/views/restaurant_orders_screen.dart';
import '../../features/partner/presentation/views/restaurant_settings_screen.dart';

import '../../features/partner/presentation/views/product_management_screen.dart';
import '../../features/partner/presentation/views/market_orders_screen.dart';
import '../../features/partner/presentation/views/market_products_screen.dart';
import '../../features/partner/presentation/views/market_home_screen.dart';
import '../../features/partner/presentation/views/user_profile_screen.dart';
import '../../features/reviews/presentation/views/partner_reviews_screen.dart';
import '../../features/partner/presentation/views/category_list_screen.dart';
import '../../features/partner/presentation/views/add_category_screen.dart';
import '../../features/partner/presentation/views/edit_category_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';
import '../../features/drivers/presentation/views/driver_orders_screen.dart';
import '../../features/auth/presentation/views/customer_profile_screen.dart';
import '../../features/support/presentation/views/create_ticket_screen.dart';
import '../../features/support/presentation/views/ticket_chat_screen.dart';
import '../../features/partner/presentation/views/partner_support_screen.dart';
import '../../features/support/domain/entities/ticket_message_entity.dart';
import '../../features/partner/presentation/views/add_product_screen.dart';
import '../../features/partner/presentation/views/edit_product_screen.dart';

import '../../features/auth/presentation/views/partner_type_selection_screen.dart';

import 'dart:async';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../core/di/injection_container.dart';

class PartnerRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthRefreshStream(InjectionContainer().authCubit.stream),
    redirect: (context, state) {
      final authState = InjectionContainer().authCubit.state;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isSplash = state.uri.toString() == '/splash';

      if (authState is AuthUnauthenticated) {
        if (!isLoggingIn && !isSigningUp && !isSplash) {
          return '/login';
        }
      }
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const PartnerSplashScreen(),
      ),
      GoRoute(
        path: '/partner-type-selection',
        name: 'partner-type-selection',
        builder: (context, state) => const PartnerTypeSelectionScreen(),
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
        builder: (context, state) => const PartnerSignupScreen(),
      ),
      // Home Redirect
      GoRoute(path: '/home', redirect: (context, state) => '/profile'),

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
            routes: [
              GoRoute(
                path: 'add',
                name: 'restaurant-add-product',
                builder: (context, state) =>
                    const AddProductScreen(), // You'll need to define this or verify import
              ),
              GoRoute(
                path: 'edit/:productId',
                name: 'restaurant-edit-product',
                builder: (context, state) {
                  final productId = state.pathParameters['productId'] ?? '';
                  return EditProductScreen(
                    productId: productId,
                  ); // You'll need to define this or verify import
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'restaurant-settings',
            builder: (context, state) => const RestaurantSettingsScreen(),
          ),
          GoRoute(
            path: 'reviews',
            name: 'restaurant-reviews',
            builder: (context, state) => const PartnerReviewsScreen(),
          ),
          GoRoute(
            path: 'categories',
            name: 'restaurant-categories',
            builder: (context, state) {
              // Get restaurantId from extra or path parameters
              String? restaurantId;
              if (state.extra is Map<String, dynamic>) {
                restaurantId =
                    (state.extra as Map<String, dynamic>)['restaurantId']
                        as String?;
              }
              // If not in extra, try to get from parent route's extra
              if (restaurantId == null) {
                // Try to get from auth/restaurant cubit as fallback
                // For now, return error - restaurants should pass restaurantId
                return const ErrorScreen();
              }
              return PartnerCategoryListScreen(restaurantId: restaurantId);
            },
            routes: [
              GoRoute(
                path: 'add',
                name: 'restaurant-add-category',
                builder: (context, state) {
                  String? restaurantId;
                  if (state.extra is Map<String, dynamic>) {
                    restaurantId =
                        (state.extra as Map<String, dynamic>)['restaurantId']
                            as String?;
                  }
                  if (restaurantId == null) {
                    return const ErrorScreen();
                  }
                  return PartnerAddCategoryScreen(restaurantId: restaurantId);
                },
              ),
              GoRoute(
                path: ':categoryId/edit',
                name: 'restaurant-edit-category',
                builder: (context, state) {
                  String? restaurantId;
                  if (state.extra is Map<String, dynamic>) {
                    restaurantId =
                        (state.extra as Map<String, dynamic>)['restaurantId']
                            as String?;
                  }
                  final categoryId = state.pathParameters['categoryId'] ?? '';
                  if (restaurantId == null || categoryId.isEmpty) {
                    return const ErrorScreen();
                  }
                  return PartnerEditCategoryScreen(
                    restaurantId: restaurantId,
                    categoryId: categoryId,
                  );
                },
              ),
            ],
          ),
          // Restaurant Support
          GoRoute(
            path: 'support',
            name: 'restaurant-support',
            builder: (context, state) => const PartnerSupportScreen(
              supportType: PartnerSupportType.restaurant,
            ),
            routes: [
              GoRoute(
                path: 'create-ticket',
                name: 'restaurant-create-ticket',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>;
                  // Inject restaurant sender role
                  final newExtras = Map<String, dynamic>.from(extras);
                  newExtras['senderRole'] = SenderRole.restaurant;
                  return CreateTicketScreen(extras: newExtras);
                },
              ),
              GoRoute(
                path: 'chat/:ticketId',
                name: 'restaurant-ticket-chat',
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>;
                  return TicketChatScreen(extras: extras);
                },
              ),
            ],
          ),
        ],
      ),

      // Profile Route (Shared)
      GoRoute(
        path: '/profile',
        name: 'partner-profile',
        builder: (context, state) => const UserProfileScreen(),
      ),

      // Driver Routes
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
          GoRoute(
            path: 'support',
            name: 'driver-support',
            builder: (context, state) => const PartnerSupportScreen(
              supportType: PartnerSupportType.driver,
            ),
            routes: [
              GoRoute(
                path: 'create-ticket',
                name: 'driver-create-ticket',
                builder: (context, state) => CreateTicketScreen(
                  extras: state.extra as Map<String, dynamic>,
                ),
              ),
              GoRoute(
                path: 'chat/:ticketId',
                name: 'driver-ticket-chat',
                builder: (context, state) => TicketChatScreen(
                  extras: state.extra as Map<String, dynamic>,
                ),
              ),
            ],
          ),
        ],
      ),

      // Market Routes
      GoRoute(
        path: '/market',
        name: 'market',
        builder: (context, state) => const MarketHomeScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            name: 'market-orders',
            builder: (context, state) => const MarketOrdersScreen(),
          ),
          GoRoute(
            path: 'products',
            name: 'market-products',
            builder: (context, state) => const MarketProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'market-add-product',
                builder: (context, state) => const AddProductScreen(),
              ),
              GoRoute(
                path: 'edit/:productId',
                name: 'market-edit-product',
                builder: (context, state) {
                  final productId = state.pathParameters['productId'] ?? '';
                  return EditProductScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: 'market-settings',
            builder: (context, state) =>
                const RestaurantSettingsScreen(), // Keep settings shared for now
          ),
          GoRoute(
            path: 'reviews',
            name: 'market-reviews',
            builder: (context, state) => const PartnerReviewsScreen(),
          ),
          GoRoute(
            path: 'support',
            name: 'market-support',
            builder: (context, state) => const PartnerSupportScreen(
              supportType: PartnerSupportType.market,
            ),
            routes: [
              GoRoute(
                path: 'create-ticket',
                name: 'market-create-ticket',
                builder: (context, state) => CreateTicketScreen(
                  extras: state.extra as Map<String, dynamic>,
                ),
              ),
              GoRoute(
                path: 'chat/:ticketId',
                name: 'market-ticket-chat',
                builder: (context, state) => TicketChatScreen(
                  extras: state.extra as Map<String, dynamic>,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class AuthRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  AuthRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
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
