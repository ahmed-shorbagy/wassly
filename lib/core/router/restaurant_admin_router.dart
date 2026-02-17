import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/admin/presentation/views/admin_splash_screen.dart';
import '../../features/admin/presentation/views/restaurant_admin_dashboard_screen.dart';
import '../../features/admin/presentation/views/restaurant_management_screen.dart';
import '../../features/admin/presentation/views/create_restaurant_screen.dart';
import '../../features/admin/presentation/views/admin_create_market_screen.dart';
import '../../features/admin/presentation/views/admin_product_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_product_screen.dart';
import '../../features/admin/presentation/views/admin_market_product_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_market_product_screen.dart';
import '../../features/admin/presentation/views/admin_edit_market_product_screen.dart';
import '../../features/admin/presentation/views/admin_edit_product_screen.dart';
import '../../features/admin/presentation/views/edit_restaurant_screen.dart';
import '../../features/admin/presentation/views/admin_category_list_screen.dart';
import '../../features/admin/presentation/views/admin_add_category_screen.dart';
import '../../features/admin/presentation/views/admin_edit_category_screen.dart';
import '../../features/admin/presentation/views/admin_restaurant_categories_screen.dart';
import '../../features/restaurants/domain/entities/restaurant_entity.dart';
import '../../features/market_products/domain/entities/market_product_entity.dart';

class RestaurantAdminRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Admin Splash Screen (No Authentication Required)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const AdminSplashScreen(),
      ),
      // Home Redirect
      GoRoute(path: '/home', redirect: (context, state) => '/admin'),

      // Admin Routes - Nested structure for proper navigation stack
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const RestaurantAdminDashboardScreen(),
        routes: [
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
                path: 'create-market',
                name: 'create-market',
                builder: (context, state) => const AdminCreateMarketScreen(),
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

          // Restaurant Categories (Global)
          GoRoute(
            path: 'restaurant-categories',
            name: 'admin-categories',
            builder: (context, state) =>
                const AdminRestaurantCategoriesScreen(),
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
