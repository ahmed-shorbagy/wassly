import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/product_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantProductsUseCase
    extends UseCase<List<ProductEntity>, String> {
  final RestaurantRepository repository;

  GetRestaurantProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(String params) async {
    return await repository.getRestaurantProducts(params);
  }
}
