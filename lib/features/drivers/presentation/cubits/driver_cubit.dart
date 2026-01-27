import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

part 'driver_state.dart';

class DriverCubit extends Cubit<DriverState> {
  final DriverRepository driverRepository;
  final AuthRepository authRepository;

  DriverCubit({required this.driverRepository, required this.authRepository})
    : super(DriverInitial());

  Future<void> loadAllDrivers() async {
    try {
      emit(DriverLoading());
      AppLogger.logInfo('Loading all drivers');

      final result = await driverRepository.getAllDrivers();

      result.fold(
        (failure) {
          AppLogger.logError('Failed to load drivers', error: failure.message);
          emit(DriverError(failure.message));
        },
        (drivers) {
          AppLogger.logSuccess('Drivers loaded: ${drivers.length}');
          emit(DriversLoaded(drivers));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading drivers', error: e);
      emit(DriverError('Failed to load drivers: $e'));
    }
  }

  Future<void> createDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleColor,
    required String vehiclePlateNumber,
    required File personalImageFile,
    required File driverLicenseFile,
    required File vehicleLicenseFile,
    required File vehiclePhotoFile,
  }) async {
    try {
      emit(DriverLoading());
      AppLogger.logInfo('Creating driver: $name');

      // First, create the user account
      final signupResult = await authRepository.signup(
        email,
        password,
        name,
        phone,
        'driver', // userType
      );

      await signupResult.fold(
        (failure) async {
          AppLogger.logError(
            'Failed to create user account',
            error: failure.message,
          );
          emit(
            DriverError('Failed to create user account: ${failure.message}'),
          );
        },
        (user) async {
          AppLogger.logSuccess('User account created: ${user.id}');

          // Create driver entity (images will be uploaded by repository)
          final driver = DriverEntity(
            id: '', // Will be set by repository
            userId: user.id,
            name: name,
            email: email,
            phone: phone,
            address: address,
            vehicleType: vehicleType,
            vehicleModel: vehicleModel,
            vehicleColor: vehicleColor,
            vehiclePlateNumber: vehiclePlateNumber,
            isActive: true,
            isOnline: false,
            createdAt: DateTime.now(),
          );

          // Add driver with image files
          final driverResult = await driverRepository.addDriverWithImages(
            driver: driver,
            personalImageFile: personalImageFile,
            driverLicenseFile: driverLicenseFile,
            vehicleLicenseFile: vehicleLicenseFile,
            vehiclePhotoFile: vehiclePhotoFile,
          );

          await driverResult.fold(
            (failure) async {
              AppLogger.logError(
                'Failed to create driver',
                error: failure.message,
              );
              emit(DriverError('Failed to create driver: ${failure.message}'));
            },
            (createdDriver) async {
              AppLogger.logSuccess(
                'Driver created successfully: ${createdDriver.name}',
              );
              emit(DriverCreated(createdDriver));
              loadAllDrivers(); // Refresh list
            },
          );
        },
      );
    } catch (e) {
      AppLogger.logError('Error creating driver', error: e);
      emit(DriverError('Failed to create driver: $e'));
    }
  }

  Future<void> updateDriver(DriverEntity driver) async {
    try {
      emit(DriverLoading());
      AppLogger.logInfo('Updating driver: ${driver.id}');

      final updatedDriver = driver.copyWith(updatedAt: DateTime.now());
      final result = await driverRepository.updateDriver(updatedDriver);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to update driver', error: failure.message);
          emit(DriverError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Driver updated successfully');
          emit(DriverUpdated(updatedDriver));
          loadAllDrivers(); // Refresh list
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating driver', error: e);
      emit(DriverError('Failed to update driver: $e'));
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      emit(DriverLoading());
      AppLogger.logInfo('Deleting driver: $driverId');

      final result = await driverRepository.deleteDriver(driverId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete driver', error: failure.message);
          emit(DriverError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Driver deleted successfully');
          emit(DriverDeleted());
          loadAllDrivers(); // Refresh list
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting driver', error: e);
      emit(DriverError('Failed to delete driver: $e'));
    }
  }

  Future<void> getDriverById(String driverId) async {
    try {
      emit(DriverLoading());
      AppLogger.logInfo('Loading driver: $driverId');

      final result = await driverRepository.getDriverById(driverId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to load driver', error: failure.message);
          emit(DriverError(failure.message));
        },
        (driver) {
          AppLogger.logSuccess('Driver loaded: ${driver.name}');
          emit(DriverLoaded(driver));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading driver', error: e);
      emit(DriverError('Failed to load driver: $e'));
    }
  }

  void resetState() {
    emit(DriverInitial());
  }
}
