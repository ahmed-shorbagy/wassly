import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../models/driver_model.dart';

class DriverRepositoryImpl implements DriverRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  final SupabaseService supabaseService;

  DriverRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
    SupabaseService? supabaseService,
  }) : supabaseService = supabaseService ?? SupabaseService();

  Future<Either<Failure, String>> _uploadDriverImage(
    File file,
    String fileName,
    String folder,
  ) async {
    try {
      AppLogger.logInfo('Uploading driver image: $fileName');
      final result = await supabaseService.uploadImage(
        file: file,
        bucketName: SupabaseConstants.driverImagesBucket,
        folder: folder,
        fileName: fileName,
      );
      return result;
    } catch (e) {
      AppLogger.logError('Error uploading driver image', error: e);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> addDriver(DriverEntity driver) async {
    if (await networkInfo.isConnected) {
      try {
        final docRef = await firestore
            .collection(AppConstants.driversCollection)
            .add(DriverModel.fromEntity(driver).toJson());
        final newDriver = driver.copyWith(id: docRef.id);
        await docRef.update({'id': docRef.id});
        return Right(newDriver);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to add driver', error: e);
        return Left(ServerFailure('Failed to add driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> addDriverWithImages({
    required DriverEntity driver,
    required File personalImageFile,
    required File driverLicenseFile,
    required File vehicleLicenseFile,
    required File vehiclePhotoFile,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        AppLogger.logInfo('Adding driver with images: ${driver.name}');

        // Upload images
        final personalImageResult = await _uploadDriverImage(
          personalImageFile,
          '${driver.userId}_personal.jpg',
          'personal',
        );
        final driverLicenseResult = await _uploadDriverImage(
          driverLicenseFile,
          '${driver.userId}_license.jpg',
          'licenses',
        );
        final vehicleLicenseResult = await _uploadDriverImage(
          vehicleLicenseFile,
          '${driver.userId}_vehicle_license.jpg',
          'licenses',
        );
        final vehiclePhotoResult = await _uploadDriverImage(
          vehiclePhotoFile,
          '${driver.userId}_vehicle.jpg',
          'vehicles',
        );

        // Check if all uploads succeeded
        String? personalImageUrl;
        String? driverLicenseUrl;
        String? vehicleLicenseUrl;
        String? vehiclePhotoUrl;

        personalImageResult.fold(
          (failure) => Left(failure),
          (url) async {
            personalImageUrl = url;
            return Right(url);
          },
        );

        driverLicenseResult.fold(
          (failure) => Left(failure),
          (url) async {
            driverLicenseUrl = url;
            return Right(url);
          },
        );

        vehicleLicenseResult.fold(
          (failure) => Left(failure),
          (url) async {
            vehicleLicenseUrl = url;
            return Right(url);
          },
        );

        vehiclePhotoResult.fold(
          (failure) => Left(failure),
          (url) async {
            vehiclePhotoUrl = url;
            return Right(url);
          },
        );

        // Create driver with image URLs
        final driverWithImages = driver.copyWith(
          personalImageUrl: personalImageUrl,
          driverLicenseUrl: driverLicenseUrl,
          vehicleLicenseUrl: vehicleLicenseUrl,
          vehiclePhotoUrl: vehiclePhotoUrl,
        );

        // Save to Firestore
        final docRef = await firestore
            .collection(AppConstants.driversCollection)
            .add(DriverModel.fromEntity(driverWithImages).toJson());
        final newDriver = driverWithImages.copyWith(id: docRef.id);
        await docRef.update({'id': docRef.id});

        AppLogger.logSuccess('Driver created with images: ${newDriver.id}');
        return Right(newDriver);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to add driver with images', error: e);
        return Left(ServerFailure('Failed to add driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDriver(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        await firestore
            .collection(AppConstants.driversCollection)
            .doc(driverId)
            .delete();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to delete driver', error: e);
        return Left(ServerFailure('Failed to delete driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<DriverEntity>>> getAllDrivers() async {
    if (await networkInfo.isConnected) {
      try {
        final snapshot = await firestore
            .collection(AppConstants.driversCollection)
            .orderBy('createdAt', descending: true)
            .get();
        final drivers = snapshot.docs
            .map((doc) => DriverModel.fromFirestore(doc))
            .toList();
        return Right(drivers);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to get all drivers', error: e);
        return Left(ServerFailure('Failed to get drivers: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> getDriverById(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final doc = await firestore
            .collection(AppConstants.driversCollection)
            .doc(driverId)
            .get();
        if (doc.exists) {
          return Right(DriverModel.fromFirestore(doc));
        } else {
          return const Left(ServerFailure('Driver not found'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to get driver by ID', error: e);
        return Left(ServerFailure('Failed to get driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> getDriverByUserId(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final snapshot = await firestore
            .collection(AppConstants.driversCollection)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return Right(DriverModel.fromFirestore(snapshot.docs.first));
        } else {
          return const Left(ServerFailure('Driver not found'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to get driver by user ID', error: e);
        return Left(ServerFailure('Failed to get driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDriver(DriverEntity driver) async {
    if (await networkInfo.isConnected) {
      try {
        await firestore
            .collection(AppConstants.driversCollection)
            .doc(driver.id)
            .update(DriverModel.fromEntity(driver).toJson());
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to update driver', error: e);
        return Left(ServerFailure('Failed to update driver: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}

