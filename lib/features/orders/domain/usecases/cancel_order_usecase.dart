import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase implements UseCase<void, String> {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.cancelOrder(params);
  }
}

