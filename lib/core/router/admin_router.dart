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
import '../../features/admin/presentation/views/admin_edit_product_screen.dart';
import '../../features/admin/presentation/views/admin_startup_ads_screen.dart';
import '../../features/admin/presentation/views/admin_banner_ads_screen.dart';
import '../../features/admin/presentation/views/admin_add_startup_ad_screen.dart';
import '../../features/admin/presentation/views/admin_edit_startup_ad_screen.dart';
import '../../features/admin/presentation/views/admin_add_banner_ad_screen.dart';
import '../../features/admin/presentation/views/admin_edit_banner_ad_screen.dart';
import '../../features/admin/presentation/views/edit_restaurant_screen.dart';
import '../../features/admin/presentation/views/admin_category_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_category_screen.dart';
import '../../features/admin/presentation/views/admin_edit_category_screen.dart';
import '../../features/admin/presentation/views/order_management_screen.dart';
import '../../features/admin/presentation/views/user_management_screen.dart';
import '../../features/admin/presentation/views/analytics_screen.dart';
import '../../features/admin/presentation/views/admin_settings_screen.dart';
import '../../features/orders/presentation/views/order_detail_screen.dart';
import '../../features/admin/presentation/views/driver_management_screen.dart';
import '../../features/admin/presentation/views/create_driver_screen.dart';
import '../../features/admin/presentation/views/edit_driver_screen.dart';
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

      // Admin Routes - Nested structure for proper navigation stack
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          // Analytics
          GoRoute(
            path: 'analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          // Users
          GoRoute(
            path: 'users',
            name: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          // Restaurants - Nested routes
          GoRoute(
            path: 'restaurants',
            name: 'restaurants',
            builder: (context, state) => const RestaurantManagementScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-restaurant',
                builder: (context, state) => const CreateRestaurantScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
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
              // Product Management Routes - Nested under restaurants
              GoRoute(
                path: ':restaurantId/products',
                name: 'admin-restaurant-products',
                builder: (context, state) {
                  final restaurantId =
                      state.pathParameters['restaurantId'] ?? '';
                  final restaurant = state.extra as Map<String, dynamic>?;
                  return AdminProductListScreen(
                    restaurantId: restaurantId,
                    restaurantName: restaurant?['name'] ?? 'Restaurant',
                  );
                },
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'admin-add-product',
                    builder: (context, state) {
                      final restaurantId =
                          state.pathParameters['restaurantId'] ?? '';
                      return AdminAddProductScreen(restaurantId: restaurantId);
                    },
                  ),
                  GoRoute(
                    path: 'edit/:productId',
                    name: 'admin-edit-product',
                    builder: (context, state) {
                      final restaurantId =
                          state.pathParameters['restaurantId'] ?? '';
                      final productId = state.pathParameters['productId'] ?? '';
                      final product = state.extra;
                      return AdminEditProductScreen(
                        restaurantId: restaurantId,
                        productId: productId,
                        product: product,
                      );
                    },
                  ),
                ],
              ),
              // Category Management Routes - Nested under restaurants
              GoRoute(
                path: ':restaurantId/categories',
                name: 'admin-restaurant-categories',
                builder: (context, state) {
                  final restaurantId =
                      state.pathParameters['restaurantId'] ?? '';
                  return AdminCategoryListScreen(restaurantId: restaurantId);
                },
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'admin-add-category',
                    builder: (context, state) {
                      final restaurantId =
                          state.pathParameters['restaurantId'] ?? '';
                      return AdminAddCategoryScreen(restaurantId: restaurantId);
                    },
                  ),
                  GoRoute(
                    path: ':categoryId/edit',
                    name: 'admin-edit-category',
                    builder: (context, state) {
                      final restaurantId =
                          state.pathParameters['restaurantId'] ?? '';
                      final categoryId =
                          state.pathParameters['categoryId'] ?? '';
                      return AdminEditCategoryScreen(
                        restaurantId: restaurantId,
                        categoryId: categoryId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Drivers
          GoRoute(
            path: 'drivers',
            name: 'drivers',
            builder: (context, state) => const DriverManagementScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-driver',
                builder: (context, state) => const CreateDriverScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-driver',
                builder: (context, state) {
                  final driverId = state.pathParameters['id'] ?? '';
                  return EditDriverScreen(driverId: driverId);
                },
              ),
            ],
          ),
          // Orders
          GoRoute(
            path: 'orders',
            name: 'orders',
            builder: (context, state) => const OrderManagementScreen(),
          ),
          // Settings
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
          // Market Products - Nested routes
          GoRoute(
            path: 'market-products',
            name: 'market-products',
            builder: (context, state) => const AdminMarketProductListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-market-product',
                builder: (context, state) =>
                    const AdminAddMarketProductScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
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
            ],
          ),
          // Ads Management - Nested routes
          GoRoute(
            path: 'ads',
            builder: (context, state) {
              // Default to startup ads screen when navigating to /admin/ads
              return const AdminStartupAdsScreen();
            },
            routes: [
              GoRoute(
                path: 'startup',
                name: 'startup-ads',
                builder: (context, state) => const AdminStartupAdsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-startup-ad',
                    builder: (context, state) =>
                        const AdminAddStartupAdScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    name: 'edit-startup-ad',
                    builder: (context, state) {
                      final adId = state.pathParameters['id'] ?? '';
                      final ad = state.extra is StartupAdEntity
                          ? state.extra as StartupAdEntity
                          : null;
                      return AdminEditStartupAdScreen(adId: adId, ad: ad);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'banners',
                name: 'banner-ads',
                builder: (context, state) => const AdminBannerAdsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-banner-ad',
                    builder: (context, state) => const AdminAddBannerAdScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
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
              ),
            ],
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

