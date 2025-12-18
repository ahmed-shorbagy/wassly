import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/restaurants/presentation/views/customer_home_screen.dart';
import '../../features/restaurants/presentation/views/favorites_screen.dart';
import '../../features/restaurants/presentation/views/restaurant_detail_screen.dart';
import '../../features/restaurants/presentation/views/search_results_screen.dart';
import '../../features/orders/presentation/views/cart_screen.dart';
import '../../features/orders/presentation/views/checkout_screen.dart';
import '../../features/orders/presentation/views/order_list_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';
import '../../features/auth/presentation/views/customer_profile_screen.dart';
import '../../features/market_products/presentation/views/market_products_screen.dart';
import '../../features/navigation/presentation/views/customer_navigation_shell.dart';
import '../../features/delivery_address/presentation/views/address_book_screen.dart';

class CustomerRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeBranch');
  static final GlobalKey<NavigatorState> _ordersNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'ordersBranch');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileBranch');
  static final GlobalKey<NavigatorState> _payNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'payBranch');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      // Redirect root path to home if authenticated, otherwise to splash
      if (state.uri.path == '/') {
        return '/splash';
      }
      return null;
    },
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

      // Customer Shell with bottom navigation
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) =>
            CustomerNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const CustomerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrderListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const CustomerProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _payNavigatorKey,
            routes: [
              GoRoute(
                path: '/cart',
                name: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          final restaurants = state.extra as List?;
          return SearchResultsScreen(
            initialQuery: query,
            initialRestaurants: restaurants?.cast(),
          );
        },
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
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
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
        path: '/order/:id',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/market-products',
        name: 'market-products',
        builder: (context, state) {
          // Pass extra data (like category) to the screen
          return MarketProductsScreen();
        },
      ),
      GoRoute(
        path: '/address-book',
        name: 'address-book',
        builder: (context, state) => const AddressBookScreen(),
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

