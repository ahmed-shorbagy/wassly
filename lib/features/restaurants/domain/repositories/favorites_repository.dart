import 'dart:async';

abstract class FavoritesRepository {
  Stream<Set<String>> streamFavoriteRestaurantIds(String userId);
  Future<void> toggleFavoriteRestaurant(String userId, String restaurantId);
}


