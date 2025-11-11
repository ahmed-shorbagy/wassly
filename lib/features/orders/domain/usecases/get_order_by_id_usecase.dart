import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(String params) async {
    return await repository.getOrderById(params);
  }
}

