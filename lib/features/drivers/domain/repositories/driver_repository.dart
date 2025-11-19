import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/driver_entity.dart';

abstract class DriverRepository {
  Future<Either<Failure, DriverEntity>> addDriver(DriverEntity driver);
  Future<Either<Failure, DriverEntity>> addDriverWithImages({
    required DriverEntity driver,
    required File personalImageFile,
    required File driverLicenseFile,
    required File vehicleLicenseFile,
    required File vehiclePhotoFile,
  });
  Future<Either<Failure, void>> updateDriver(DriverEntity driver);
  Future<Either<Failure, void>> deleteDriver(String driverId);
  Future<Either<Failure, List<DriverEntity>>> getAllDrivers();
  Future<Either<Failure, DriverEntity>> getDriverById(String driverId);
  Future<Either<Failure, DriverEntity>> getDriverByUserId(String userId);
}

