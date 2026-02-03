import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final userCredential = await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          final userDoc = await firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            if (userDoc.data()?['isActive'] == false) {
              return const Left(
                AuthFailure(
                  'Your account is pending admin approval. Please wait.',
                ),
              );
            }
            final userModel = UserModel.fromJson({
              'id': userCredential.user!.uid,
              ...userDoc.data()!,
            });
            return Right(userModel);
          } else {
            return const Left(AuthFailure('User data not found'));
          }
        } else {
          AppLogger.logError('Login failed: user credential is null');
          return const Left(AuthFailure('Login failed'));
        }
      } on FirebaseAuthException catch (e) {
        AppLogger.logError(
          'Firebase Auth Exception during login',
          error: 'Code: ${e.code}, Message: ${e.message}',
        );
        final errorMessage = _mapFirebaseAuthException(e);
        AppLogger.logAuth('Mapped error message: $errorMessage');
        return Left(AuthFailure(errorMessage));
      } on ServerException catch (e) {
        AppLogger.logError('Server Exception during login', error: e.message);
        return Left(ServerFailure(e.message));
      } catch (e, stackTrace) {
        AppLogger.logError(
          'Unknown error during login',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup(
    String email,
    String password,
    String name,
    String phone,
    String userType,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          final userModel = UserModel(
            id: userCredential.user!.uid,
            email: email,
            name: name,
            phone: phone,
            userType: userType,
            createdAt: DateTime.now(),
            isActive: true,
          );

          await firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(userModel.toJson());

          return Right(userModel);
        } else {
          AppLogger.logError('Signup failed: user credential is null');
          return const Left(AuthFailure('Signup failed'));
        }
      } on FirebaseAuthException catch (e) {
        AppLogger.logError(
          'Firebase Auth Exception during signup',
          error: 'Code: ${e.code}, Message: ${e.message}',
        );
        final errorMessage = _mapFirebaseAuthException(e);
        AppLogger.logAuth('Mapped error message: $errorMessage');
        return Left(AuthFailure(errorMessage));
      } on ServerException catch (e) {
        AppLogger.logError('Server Exception during signup', error: e.message);
        return Left(ServerFailure(e.message));
      } catch (e, stackTrace) {
        AppLogger.logError(
          'Unknown error during signup',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      AppLogger.logAuth('Attempting logout');
      await firebaseAuth.signOut();
      AppLogger.logSuccess('Logout successful');
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.logError('Logout failed', error: e, stackTrace: stackTrace);
      return Left(AuthFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      AppLogger.logAuth('Getting current user');
      final user = firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.logInfo('Firebase user found: ${user.email}');
        final userDoc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          AppLogger.logSuccess('User document found in Firestore');
          final userModel = UserModel.fromJson({
            'id': user.uid,
            ...userDoc.data()!,
          });
          return Right(userModel);
        } else {
          AppLogger.logWarning(
            'User document not found in Firestore for UID: ${user.uid}',
          );
        }
      } else {
        AppLogger.logInfo('No current Firebase user');
      }
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.logError(
        'Failed to get current user',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel.fromEntity(user);
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .update(userModel.toJson());
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Failed to update profile'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await firebaseAuth.sendPasswordResetEmail(email: email);
        AppLogger.logSuccess('Password reset email sent to $email');
        return const Right(null);
      } on FirebaseAuthException catch (e) {
        AppLogger.logError(
          'Firebase Auth Exception during password reset',
          error: 'Code: ${e.code}, Message: ${e.message}',
        );
        final errorMessage = _mapFirebaseAuthException(e);
        return Left(AuthFailure(errorMessage));
      } catch (e, stackTrace) {
        AppLogger.logError(
          'Unknown error during password reset',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(ServerFailure('Failed to send password reset email'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final user = firebaseAuth.currentUser;
        if (user == null) {
          return const Left(AuthFailure('User not authenticated'));
        }

        // Re-authenticate user with current password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
        AppLogger.logSuccess('Password changed successfully');
        return const Right(null);
      } on FirebaseAuthException catch (e) {
        AppLogger.logError(
          'Firebase Auth Exception during password change',
          error: 'Code: ${e.code}, Message: ${e.message}',
        );
        final errorMessage = _mapFirebaseAuthException(e);
        return Left(AuthFailure(errorMessage));
      } catch (e, stackTrace) {
        AppLogger.logError(
          'Unknown error during password change',
          error: e,
          stackTrace: stackTrace,
        );
        return Left(ServerFailure('Failed to change password'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    AppLogger.logAuth('Mapping Firebase error code: ${e.code}');

    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        AppLogger.logWarning('Unmapped Firebase error code: ${e.code}');
        return 'An error occurred: ${e.message ?? 'Unknown error'}';
    }
  }
}
