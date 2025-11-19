import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/utils/use_case.dart';
import '../../../../core/utils/logger.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository repository;

  AuthCubit({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.resetPasswordUseCase,
    required this.repository,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    AppLogger.logAuth('Attempting login for email: $email');
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        AppLogger.logError('Login failed', error: failure.message);
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.logSuccess(
          'Login successful for user: ${user.name} (${user.userType})',
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    AppLogger.logAuth(
      'Attempting signup for email: $email, userType: $userType',
    );
    emit(AuthLoading());

    final result = await signupUseCase(
      SignupParams(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.logError('Signup failed', error: failure.message);
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.logSuccess(
          'Signup successful for user: ${user.name} (${user.userType})',
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> logout() async {
    AppLogger.logAuth('Attempting logout');
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        AppLogger.logError('Logout failed', error: failure.message);
        emit(AuthError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Logout successful');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> getCurrentUser() async {
    AppLogger.logAuth('Checking current user');
    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) {
        AppLogger.logWarning(
          'No current user found or error: ${failure.message}',
        );
        emit(AuthError(failure.message));
      },
      (user) {
        if (user != null) {
          AppLogger.logSuccess(
            'Current user found: ${user.name} (${user.userType})',
          );
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.logInfo('No authenticated user');
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> resetPassword(String email) async {
    AppLogger.logAuth('Attempting password reset for email: $email');
    emit(AuthLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(email: email),
    );

    result.fold(
      (failure) {
        AppLogger.logError('Password reset failed', error: failure.message);
        emit(AuthError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Password reset email sent successfully');
        emit(AuthPasswordResetSent());
      },
    );
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    AppLogger.logAuth('Attempting password change');
    emit(AuthLoading());

    final result = await repository.changePassword(
      currentPassword,
      newPassword,
    );

    result.fold(
      (failure) {
        AppLogger.logError('Password change failed', error: failure.message);
        emit(AuthError(failure.message));
      },
      (_) {
        AppLogger.logSuccess('Password changed successfully');
        emit(AuthPasswordChanged());
      },
    );
  }
}
