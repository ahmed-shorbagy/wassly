import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
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
            final userModel = UserModel.fromJson({
              'id': userCredential.user!.uid,
              ...userDoc.data()!,
            });
            return Right(userModel);
          } else {
            return const Left(AuthFailure('User data not found'));
          }
        } else {
          return const Left(AuthFailure('Login failed'));
        }
      } on FirebaseAuthException catch (e) {
        return Left(AuthFailure(_mapFirebaseAuthException(e)));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unknown error occurred'));
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
          return const Left(AuthFailure('Signup failed'));
        }
      } on FirebaseAuthException catch (e) {
        return Left(AuthFailure(_mapFirebaseAuthException(e)));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unknown error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(AuthFailure('Logout failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        final userDoc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromJson({
            'id': user.uid,
            ...userDoc.data()!,
          });
          return Right(userModel);
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to get current user'));
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

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred during authentication.';
    }
  }
}
