import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';
import '../../../drivers/domain/repositories/driver_repository.dart';
import '../../../drivers/domain/entities/driver_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/app_constants.dart';
import 'partner_signup_state.dart';

class PartnerSignupCubit extends Cubit<PartnerSignupState> {
  final AuthRepository authRepository;
  final RestaurantOwnerRepository restaurantOwnerRepository;
  final DriverRepository driverRepository;

  PartnerSignupCubit({
    required this.authRepository,
    required this.restaurantOwnerRepository,
    required this.driverRepository,
  }) : super(PartnerSignupInitial());

  Future<void> signupRestaurantOrMarket({
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required String password,
    required List<String> categoryIds,
    required LatLng location,
    File? imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
    required String userType,
  }) async {
    emit(const PartnerSignupLoading(message: 'Creating account...'));

    final result = await restaurantOwnerRepository.createRestaurant(
      name: name,
      description: description,
      address: address,
      phone: phone,
      email: email,
      password: password,
      categoryIds: categoryIds,
      location: location,
      imageFile: imageFile,
      deliveryFee: deliveryFee,
      minOrderAmount: minOrderAmount,
      estimatedDeliveryTime: estimatedDeliveryTime,
      commercialRegistrationPhotoFile: commercialRegistrationPhotoFile,
      userType: userType,
    );

    result.fold(
      (failure) => emit(PartnerSignupError(failure.message)),
      (id) => emit(
        PartnerSignupSuccess(
          message:
              '${userType == AppConstants.userTypeMarket ? 'Market' : 'Restaurant'} registered successfully!',
          userType: userType,
        ),
      ),
    );
  }

  Future<void> signupDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehiclePlate,
    required File personalImageFile,
    required File driverLicenseFile,
    required File vehicleLicenseFile,
    required File vehiclePhotoFile,
  }) async {
    emit(const PartnerSignupLoading(message: 'Creating driver account...'));

    // 1. Create Auth User
    final authResult = await authRepository.signup(
      email,
      password,
      name,
      phone,
      AppConstants.userTypeDriver,
    );

    await authResult.fold(
      (failure) async {
        emit(PartnerSignupError(failure.message));
      },
      (user) async {
        emit(
          const PartnerSignupLoading(message: 'Uploading document photos...'),
        );

        // 2. Create Driver Document with Images
        final driverEntity = DriverEntity(
          id: '', // Will be set by Firestore
          userId: user.id,
          name: name,
          email: email,
          phone: phone,
          vehicleType: vehicleType,
          vehiclePlateNumber: vehiclePlate,
          isOnline: false,
          isActive: false, // Wait for admin approval
          rating: 0.0,
          totalDeliveries: 0,
          createdAt: DateTime.now(),
        );

        final driverResult = await driverRepository.addDriverWithImages(
          driver: driverEntity,
          personalImageFile: personalImageFile,
          driverLicenseFile: driverLicenseFile,
          vehicleLicenseFile: vehicleLicenseFile,
          vehiclePhotoFile: vehiclePhotoFile,
        );

        driverResult.fold(
          (failure) => emit(PartnerSignupError(failure.message)),
          (_) => emit(
            const PartnerSignupSuccess(
              message:
                  'Driver registered successfully! Please wait for admin approval.',
              userType: AppConstants.userTypeDriver,
            ),
          ),
        );
      },
    );
  }
}
