import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../restaurants/domain/repositories/favorites_repository.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository repository;
  final FirebaseAuth firebaseAuth;

  Stream<Set<String>>? _subscription;

  FavoritesCubit({
    required this.repository,
    required this.firebaseAuth,
  }) : super(const FavoritesState.initial());

  Future<void> start() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    await _subscription?.drain();
    _subscription = repository.streamFavoriteRestaurantIds(user.uid);
    _subscription!.listen((ids) {
      emit(state.copyWith(favoriteRestaurantIds: ids, isLoaded: true));
    });
  }

  Future<void> toggleRestaurant(String restaurantId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    await repository.toggleFavoriteRestaurant(user.uid, restaurantId);
  }

  bool isRestaurantFavorite(String restaurantId) {
    return state.favoriteRestaurantIds.contains(restaurantId);
  }
}


