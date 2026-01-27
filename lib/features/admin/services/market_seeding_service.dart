import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../presentation/cubits/admin_cubit.dart';
import '../presentation/cubits/admin_restaurant_category_cubit.dart';
import '../../../../core/constants/market_product_categories.dart';
import '../../../../l10n/app_localizations.dart';

class MarketSeedingService {
  static Future<void> seedDefaultMarkets(
    AdminCubit adminCubit,
    AdminRestaurantCategoryCubit categoryCubit,
    AppLocalizations l10n,
  ) async {
    // 1. Seed Categories
    final categoriesToSeed = [
      {
        'id': MarketProductCategories.fruitsVegetables,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.fruitsVegetables,
          l10n,
        ),
        'isMarket': true,
      },
      {
        'id': MarketProductCategories.pharmacy,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.pharmacy,
          l10n,
        ),
        'isMarket': true,
      },
      {
        'id': MarketProductCategories.cakeAndCoffee,
        'name': MarketProductCategories.getCategoryName(
          MarketProductCategories.cakeAndCoffee,
          l10n,
        ),
        'isMarket': true,
      },
    ];

    for (final cat in categoriesToSeed) {
      await categoryCubit.createCategory(
        id: cat['id'] as String,
        name: cat['name'] as String,
        isMarket: cat['isMarket'] as bool,
      );
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // 2. Seed Markets
    final marketsToSeed = [
      {
        'name': 'Fresh Fruits & Vegetables',
        'description':
            'Your daily dose of fresh organic fruits and vegetables.',
        'address': 'Main Street, Market District',
        'phone': '01234567890',
        'email': 'fruits@wassly.com',
        'password': 'password123',
        'categoryIds': [MarketProductCategories.fruitsVegetables],
        'location': const LatLng(30.0444, 31.2357),
        'deliveryFee': 15.0,
        'minOrderAmount': 50.0,
        'estimatedDeliveryTime': 30,
      },
      {
        'name': 'Community Pharmacy',
        'description': 'Reliable healthcare and medicines at your doorstep.',
        'address': 'Health Ave, Downtown',
        'phone': '01234567891',
        'email': 'pharmacy@wassly.com',
        'password': 'password123',
        'categoryIds': [MarketProductCategories.pharmacy],
        'location': const LatLng(30.0500, 31.2400),
        'deliveryFee': 10.0,
        'minOrderAmount': 20.0,
        'estimatedDeliveryTime': 20,
      },
      {
        'name': 'The Sweetest Treats',
        'description': 'Delicious cakes, pastries and premium coffee.',
        'address': 'Baker Street, Old Town',
        'phone': '01234567892',
        'email': 'cafe@wassly.com',
        'password': 'password123',
        'categoryIds': [MarketProductCategories.cakeAndCoffee],
        'location': const LatLng(30.0600, 31.2500),
        'deliveryFee': 12.0,
        'minOrderAmount': 30.0,
        'estimatedDeliveryTime': 25,
      },
    ];

    for (final market in marketsToSeed) {
      await adminCubit.createRestaurant(
        name: market['name'] as String,
        description: market['description'] as String,
        address: market['address'] as String,
        phone: market['phone'] as String,
        email: market['email'] as String,
        password: market['password'] as String,
        categoryIds: market['categoryIds'] as List<String>,
        location: market['location'] as LatLng,
        deliveryFee: market['deliveryFee'] as double,
        minOrderAmount: market['minOrderAmount'] as double,
        estimatedDeliveryTime: market['estimatedDeliveryTime'] as int,
        imageFile: null,
      );
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
