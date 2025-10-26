import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_all_restaurants_usecase.dart';
import '../../domain/usecases/get_restaurant_by_id_usecase.dart';
import '../../domain/usecases/get_restaurant_products_usecase.dart';
import '../../../../core/utils/use_case.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final GetAllRestaurantsUseCase getAllRestaurantsUseCase;
  final GetRestaurantByIdUseCase getRestaurantByIdUseCase;
  final GetRestaurantProductsUseCase getRestaurantProductsUseCase;

  RestaurantCubit({
    required this.getAllRestaurantsUseCase,
    required this.getRestaurantByIdUseCase,
    required this.getRestaurantProductsUseCase,
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
    emit(RestaurantLoading());

    final result = await getRestaurantProductsUseCase(restaurantId);

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }
}
