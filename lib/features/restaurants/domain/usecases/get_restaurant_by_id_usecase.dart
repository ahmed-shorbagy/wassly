import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantByIdUseCase extends UseCase<RestaurantEntity, String> {
  final RestaurantRepository repository;

  GetRestaurantByIdUseCase(this.repository);

  @override
  Future<Either<Failure, RestaurantEntity>> call(String params) async {
    return await repository.getRestaurantById(params);
  }
}
