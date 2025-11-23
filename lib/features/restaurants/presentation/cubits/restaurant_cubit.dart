import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_all_restaurants_usecase.dart';
import '../../domain/usecases/get_restaurant_by_id_usecase.dart';
import '../../domain/usecases/get_restaurant_products_usecase.dart';
import '../../domain/repositories/restaurant_owner_repository.dart';
import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/logger.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final GetAllRestaurantsUseCase getAllRestaurantsUseCase;
  final GetRestaurantByIdUseCase getRestaurantByIdUseCase;
  final GetRestaurantProductsUseCase getRestaurantProductsUseCase;
  final RestaurantOwnerRepository? restaurantOwnerRepository;

  RestaurantCubit({
    required this.getAllRestaurantsUseCase,
    required this.getRestaurantByIdUseCase,
    required this.getRestaurantProductsUseCase,
    this.restaurantOwnerRepository,
  }) : super(RestaurantInitial());

  Future<void> getAllRestaurants() async {
    emit(RestaurantLoading());

    final result = await getAllRestaurantsUseCase(NoParams());

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> getRestaurantById(String id) async {
    emit(RestaurantLoading());

    final result = await getRestaurantByIdUseCase(id);

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) => emit(RestaurantLoaded(restaurant)),
    );
  }

  Future<void> getRestaurantProducts(String restaurantId) async {
    AppLogger.logInfo('Fetching products for restaurant: $restaurantId');
    // Don't emit loading state to avoid overwriting restaurant state
    // Just fetch products and emit ProductsLoaded
    final result = await getRestaurantProductsUseCase(restaurantId);

    result.fold(
      (failure) {
        AppLogger.logError('Failed to fetch products for restaurant: $restaurantId', error: failure.message);
        // If there's an error, still emit ProductsLoaded with empty list
        // to avoid breaking the UI
        emit(ProductsLoaded([]));
      },
      (products) {
        AppLogger.logSuccess('Products fetched: ${products.length} for restaurant: $restaurantId');
        emit(ProductsLoaded(products));
      },
    );
  }

  Future<void> getRestaurantByOwnerId(String ownerId) async {
    if (restaurantOwnerRepository == null) {
      emit(const RestaurantError('Restaurant owner repository not available'));
      return;
    }

    emit(RestaurantLoading());

    final result = await restaurantOwnerRepository!.getRestaurantByOwnerId(ownerId);

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurant) => emit(RestaurantLoaded(restaurant)),
    );
  }
}
