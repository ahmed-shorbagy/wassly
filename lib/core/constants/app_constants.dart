class AppConstants {
  // App Info
  static const String appName = 'To Order';
  static const String appVersion = '1.0.0';

  // User Types
  static const String userTypeCustomer = 'customer';
  static const String userTypeRestaurant = 'restaurant';
  static const String userTypeMarket = 'market';
  static const String userTypeDriver = 'driver';
  static const String userTypeAdmin = 'admin';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusAccepted = 'accepted';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusPickedUp = 'picked_up';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String driversCollection = 'drivers';
  static const String foodCategoriesCollection = 'food_categories';
  static const String articlesCollection = 'articles';

  // Storage Paths
  static const String restaurantImagesPath = 'restaurants';
  static const String productImagesPath = 'products';
  static const String profileImagesPath = 'profiles';

  // API Keys (to be added to environment variables)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
