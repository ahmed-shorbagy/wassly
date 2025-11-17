import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore firestore;
  FavoritesRepositoryImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _userFavoritesCol(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favorites');
  }

  @override
  Stream<Set<String>> streamFavoriteRestaurantIds(String userId) {
    return _userFavoritesCol(userId)
        .doc('restaurants')
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return <String>{};
      final list = (data['ids'] as List?)?.cast<String>() ?? <String>[];
      return list.toSet();
    });
  }

  @override
  Future<void> toggleFavoriteRestaurant(String userId, String restaurantId) async {
    final ref = _userFavoritesCol(userId).doc('restaurants');
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = <String>{}
        ..addAll(((snap.data()?['ids'] as List?)?.cast<String>() ?? <String>[]));
      var incrementBy = 0;
      if (current.contains(restaurantId)) {
        current.remove(restaurantId);
        incrementBy = -1;
      } else {
        current.add(restaurantId);
        incrementBy = 1;
      }
      tx.set(ref, {'ids': current.toList()}, SetOptions(merge: true));
      // Also update aggregate count on the restaurant document
      final restaurantRef = firestore.collection('restaurants').doc(restaurantId);
      tx.set(restaurantRef, {
        'favoritesCount': FieldValue.increment(incrementBy),
      }, SetOptions(merge: true));
    });
  }
}


