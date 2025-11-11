import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetActiveOrdersUseCase implements UseCase<List<OrderEntity>, String> {
  final OrderRepository repository;

  GetActiveOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(String params) async {
    return await repository.getActiveOrders(params);
  }
}

