import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';

part 'restaurant_onboarding_state.dart';

class RestaurantOnboardingCubit extends Cubit<RestaurantOnboardingState> {
  final RestaurantOwnerRepository repository;

  RestaurantOnboardingCubit({required this.repository})
    : super(RestaurantOnboardingInitial());

  Future<void> createRestaurant({
    required String ownerId,
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required List<String> categories,
    required String imagePath,
    LatLng? location,
    double deliveryFee = 0.0,
    double minOrderAmount = 0.0,
    int estimatedDeliveryTime = 30,
  }) async {
    try {
      emit(RestaurantOnboardingLoading());
      AppLogger.logInfo('Creating restaurant: $name');

      // Use default location if not provided (Cairo, Egypt)
      final restaurantLocation = location ?? const LatLng(30.0444, 31.2357);

      // Create restaurant using the repository method
      final result = await repository.createRestaurant(
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
        categories: categories,
        location: restaurantLocation,
        imageFile: File(imagePath),
        deliveryFee: deliveryFee,
        minOrderAmount: minOrderAmount,
        estimatedDeliveryTime: estimatedDeliveryTime,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to create restaurant',
            error: failure.message,
          );
          emit(RestaurantOnboardingError(failure.message));
        },
        (restaurantId) {
          AppLogger.logSuccess('Restaurant created: $restaurantId');

          // Create a restaurant entity for the success state
          final restaurant = RestaurantEntity(
            id: restaurantId,
            ownerId: ownerId,
            name: name,
            description: description,
            imageUrl: null, // Will be set after upload
            address: address,
            phone: phone,
            email: email,
            categories: categories,
            location: {
              'latitude': restaurantLocation.latitude,
              'longitude': restaurantLocation.longitude,
            },
            isOpen: true,
            rating: 0.0,
            totalReviews: 0,
            deliveryFee: deliveryFee,
            minOrderAmount: minOrderAmount,
            estimatedDeliveryTime: estimatedDeliveryTime,
            createdAt: DateTime.now(),
          );

          emit(RestaurantOnboardingSuccess(restaurant));
        },
      );
    } catch (e) {
      AppLogger.logError('Error creating restaurant', error: e);
      emit(const RestaurantOnboardingError('Failed to create restaurant'));
    }
  }
}
