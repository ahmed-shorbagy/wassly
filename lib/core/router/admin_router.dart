import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/admin/presentation/views/admin_splash_screen.dart';
import '../../features/admin/presentation/views/admin_dashboard_screen.dart';
import '../../features/admin/presentation/views/restaurant_management_screen.dart';
import '../../features/admin/presentation/views/create_restaurant_screen.dart';
import '../../features/admin/presentation/views/admin_product_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_product_screen.dart';
import '../../features/admin/presentation/views/admin_market_product_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_market_product_screen.dart';
import '../../features/admin/presentation/views/admin_edit_market_product_screen.dart';
import '../../features/admin/presentation/views/admin_startup_ads_screen.dart';
import '../../features/admin/presentation/views/admin_banner_ads_screen.dart';
import '../../features/admin/presentation/views/admin_add_startup_ad_screen.dart';
import '../../features/admin/presentation/views/admin_edit_startup_ad_screen.dart';
import '../../features/admin/presentation/views/admin_add_banner_ad_screen.dart';
import '../../features/admin/presentation/views/admin_edit_banner_ad_screen.dart';
import '../../features/admin/presentation/views/edit_restaurant_screen.dart';
import '../../features/restaurants/domain/entities/restaurant_entity.dart';
import '../../features/market_products/domain/entities/market_product_entity.dart';
import '../../features/ads/domain/entities/startup_ad_entity.dart';
import '../../features/home/domain/entities/banner_entity.dart';

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
      // Market Products Routes
      GoRoute(
        path: '/admin/market-products',
        name: 'market-products',
        builder: (context, state) => const AdminMarketProductListScreen(),
      ),
      GoRoute(
        path: '/admin/market-products/add',
        name: 'add-market-product',
        builder: (context, state) => const AdminAddMarketProductScreen(),
      ),
      GoRoute(
        path: '/admin/market-products/edit/:id',
        name: 'edit-market-product',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          final product = state.extra is MarketProductEntity
              ? state.extra as MarketProductEntity
              : null;
          return AdminEditMarketProductScreen(
            productId: productId,
            product: product,
          );
        },
      ),
      // Ads Management Routes
      GoRoute(
        path: '/admin/ads/startup',
        name: 'startup-ads',
        builder: (context, state) => const AdminStartupAdsScreen(),
      ),
      GoRoute(
        path: '/admin/ads/startup/add',
        name: 'add-startup-ad',
        builder: (context, state) => const AdminAddStartupAdScreen(),
      ),
      GoRoute(
        path: '/admin/ads/startup/edit/:id',
        name: 'edit-startup-ad',
        builder: (context, state) {
          final adId = state.pathParameters['id'] ?? '';
          final ad = state.extra is StartupAdEntity
              ? state.extra as StartupAdEntity
              : null;
          return AdminEditStartupAdScreen(
            adId: adId,
            ad: ad,
          );
        },
      ),
      GoRoute(
        path: '/admin/ads/banners',
        name: 'banner-ads',
        builder: (context, state) => const AdminBannerAdsScreen(),
      ),
      GoRoute(
        path: '/admin/ads/banners/add',
        name: 'add-banner-ad',
        builder: (context, state) => const AdminAddBannerAdScreen(),
      ),
      GoRoute(
        path: '/admin/ads/banners/edit/:id',
        name: 'edit-banner-ad',
        builder: (context, state) {
          final bannerId = state.pathParameters['id'] ?? '';
          final banner = state.extra is BannerEntity
              ? state.extra as BannerEntity
              : null;
          return AdminEditBannerAdScreen(
            bannerId: bannerId,
            banner: banner,
          );
        },
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
