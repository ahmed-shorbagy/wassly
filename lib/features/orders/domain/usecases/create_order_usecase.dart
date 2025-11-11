import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, OrderEntity> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(OrderEntity params) async {
    return await repository.createOrder(params);
  }
}

