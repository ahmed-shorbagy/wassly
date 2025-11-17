import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String email;

  ResetPasswordParams({required this.email});
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(params.email);
  }
}

