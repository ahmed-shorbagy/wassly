import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetAllRestaurantsUseCase
    implements UseCase<List<RestaurantEntity>, NoParams> {
  final RestaurantRepository repository;

  GetAllRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RestaurantEntity>>> call(NoParams params) async {
    return await repository.getAllRestaurants();
  }
}
