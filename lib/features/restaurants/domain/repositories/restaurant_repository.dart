import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_entity.dart';
import '../entities/product_entity.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants();
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id);
  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(
    String restaurantId,
  );
  Future<Either<Failure, ProductEntity>> getProductById(String productId);
}
