import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignupUseCase implements UseCase<UserEntity, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignupParams params) async {
    return await repository.signup(
      params.email,
      params.password,
      params.name,
      params.phone,
      params.userType,
    );
  }
}

class SignupParams {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String userType;

  SignupParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.userType,
  });
}
