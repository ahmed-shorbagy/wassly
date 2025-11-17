part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  final Set<String> favoriteRestaurantIds;
  final bool isLoaded;

  const FavoritesState({
    required this.favoriteRestaurantIds,
    required this.isLoaded,
  });

  const FavoritesState.initial()
      : favoriteRestaurantIds = const {},
        isLoaded = false;

  FavoritesState copyWith({
    Set<String>? favoriteRestaurantIds,
    bool? isLoaded,
  }) {
    return FavoritesState(
      favoriteRestaurantIds:
          favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [favoriteRestaurantIds, isLoaded];
}


