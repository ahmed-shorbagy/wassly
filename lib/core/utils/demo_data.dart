import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class DemoData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createDemoData() async {
    AppLogger.logInfo('Creating demo data...');

    try {
      // Create demo restaurants
      await _createDemoRestaurants();
      AppLogger.logSuccess('Demo data created successfully');
    } catch (e) {
      AppLogger.logError('Error creating demo data', error: e);
    }
  }

  static Future<void> _createDemoRestaurants() async {
    final restaurants = [
      {
        'name': 'Pizza Palace',
        'description':
            'The best pizza in town with fresh ingredients and authentic Italian flavors',
        'imageUrl':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
        'address': '123 Main Street, Downtown',
        'location': GeoPoint(40.7128, -74.0060),
        'isOpen': true,
        'createdAt': Timestamp.now(),
        'ownerId': 'demo_owner_1',
      },
      {
        'name': 'Burger King',
        'description': 'Delicious burgers and fries served fresh daily',
        'imageUrl':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        'address': '456 Food Avenue, Midtown',
        'location': GeoPoint(40.7580, -73.9855),
        'isOpen': true,
        'createdAt': Timestamp.now(),
        'ownerId': 'demo_owner_2',
      },
      {
        'name': 'Sushi Master',
        'description':
            'Fresh sushi and Japanese cuisine prepared by expert chefs',
        'imageUrl':
            'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        'address': '789 Ocean Drive, Waterfront',
        'location': GeoPoint(40.7282, -73.9942),
        'isOpen': true,
        'createdAt': Timestamp.now(),
        'ownerId': 'demo_owner_3',
      },
      {
        'name': 'Coffee Corner',
        'description':
            'Artisan coffee and fresh pastries, perfect for breakfast and brunch',
        'imageUrl':
            'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
        'address': '321 Brew Street, Arts District',
        'location': GeoPoint(40.7505, -73.9934),
        'isOpen': true,
        'createdAt': Timestamp.now(),
        'ownerId': 'demo_owner_4',
      },
      {
        'name': 'Taco Fiesta',
        'description': 'Authentic Mexican tacos and burritos with spicy salsas',
        'imageUrl':
            'https://images.unsplash.com/photo-1565299585323-38174c5e5bc2?w=500',
        'address': '555 Spice Road, Market District',
        'location': GeoPoint(40.7614, -73.9776),
        'isOpen': false,
        'createdAt': Timestamp.now(),
        'ownerId': 'demo_owner_5',
      },
    ];

    final products = [
      // Pizza Palace Products
      {
        'restaurantId': 'pizza_palace',
        'name': 'Margherita Pizza',
        'description': 'Fresh mozzarella, tomato sauce, and basil',
        'price': 15.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
        'category': 'Pizza',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'pizza_palace',
        'name': 'Pepperoni Pizza',
        'description': 'Classic pepperoni with extra cheese',
        'price': 18.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500',
        'category': 'Pizza',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'pizza_palace',
        'name': 'Vegetarian Pizza',
        'description': 'Loaded with fresh vegetables',
        'price': 17.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=500',
        'category': 'Pizza',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      // Burger King Products
      {
        'restaurantId': 'burger_king',
        'name': 'Classic Burger',
        'description':
            'Juicy beef patty with lettuce, tomato, and special sauce',
        'price': 12.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        'category': 'Burgers',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'burger_king',
        'name': 'Cheese Burger',
        'description': 'Double cheese with crispy bacon',
        'price': 14.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500',
        'category': 'Burgers',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'burger_king',
        'name': 'French Fries',
        'description': 'Crispy golden fries with ketchup',
        'price': 4.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500',
        'category': 'Sides',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      // Sushi Master Products
      {
        'restaurantId': 'sushi_master',
        'name': 'Salmon Roll',
        'description': 'Fresh salmon with avocado and cucumber',
        'price': 22.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
        'category': 'Sushi',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'sushi_master',
        'name': 'Tuna Sashimi',
        'description': 'Premium fresh tuna slices',
        'price': 28.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500',
        'category': 'Sashimi',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'sushi_master',
        'name': 'California Roll',
        'description': 'Crab, avocado, and cucumber',
        'price': 16.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1617195698409-1c8ee16fc3e2?w=500',
        'category': 'Sushi',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      // Coffee Corner Products
      {
        'restaurantId': 'coffee_corner',
        'name': 'Cappuccino',
        'description': 'Rich espresso with steamed milk foam',
        'price': 5.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=500',
        'category': 'Coffee',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'coffee_corner',
        'name': 'Croissant',
        'description': 'Buttery French croissant',
        'price': 3.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500',
        'category': 'Pastries',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'coffee_corner',
        'name': 'Avocado Toast',
        'description': 'Smashed avocado on sourdough with poached eggs',
        'price': 9.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=500',
        'category': 'Breakfast',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      // Taco Fiesta Products
      {
        'restaurantId': 'taco_fiesta',
        'name': 'Beef Tacos',
        'description': 'Three soft tacos with seasoned beef',
        'price': 11.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1565299585323-38174c5e5bc2?w=500',
        'category': 'Tacos',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
      {
        'restaurantId': 'taco_fiesta',
        'name': 'Chicken Burrito',
        'description': 'Large burrito with rice, beans, and chicken',
        'price': 13.99,
        'imageUrl':
            'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500',
        'category': 'Burritos',
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      },
    ];

    // Check if restaurants already exist
    final existingRestaurants = await _firestore
        .collection(AppConstants.restaurantsCollection)
        .get();

    if (existingRestaurants.docs.isEmpty) {
      AppLogger.logInfo('Creating demo restaurants...');

      int restaurantIndex = 0;
      for (final restaurantData in restaurants) {
        final docRef = await _firestore
            .collection(AppConstants.restaurantsCollection)
            .add(restaurantData);

        final restaurantId = docRef.id;
        AppLogger.logSuccess(
          'Created restaurant: ${restaurantData['name']} with ID: $restaurantId',
        );

        // Add products for this restaurant
        final restaurantKeys = [
          'pizza_palace',
          'burger_king',
          'sushi_master',
          'coffee_corner',
          'taco_fiesta',
        ];
        final restaurantProducts = products
            .where((p) => p['restaurantId'] == restaurantKeys[restaurantIndex])
            .toList();

        for (final productData in restaurantProducts) {
          final productRef = {...productData, 'restaurantId': restaurantId};
          await _firestore
              .collection(AppConstants.productsCollection)
              .add(productRef);
        }
        AppLogger.logInfo(
          'Added ${restaurantProducts.length} products to ${restaurantData['name']}',
        );
        restaurantIndex++;
      }
    } else {
      AppLogger.logInfo('Demo restaurants already exist, skipping creation');
    }
  }
}
