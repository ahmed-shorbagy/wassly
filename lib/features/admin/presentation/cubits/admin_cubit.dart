import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final RestaurantOwnerRepository repository;

  AdminCubit({required this.repository}) : super(AdminInitial());

  Future<void> createRestaurant({
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required String password,
    required List<String> categories,
    required LatLng location,
    required File imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
  }) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Creating restaurant: $name');

      final result = await repository.createRestaurant(
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
        password: password,
        categories: categories,
        location: location,
        imageFile: imageFile,
        deliveryFee: deliveryFee,
        minOrderAmount: minOrderAmount,
        estimatedDeliveryTime: estimatedDeliveryTime,
        commercialRegistrationPhotoFile: commercialRegistrationPhotoFile,
      );

      result.fold(
        (failure) {
          AppLogger.logError('Failed to create restaurant', error: failure.message);
          emit(AdminError(failure.message));
        },
        (restaurantId) {
          AppLogger.logSuccess('Restaurant created with ID: $restaurantId');
          emit(RestaurantCreatedSuccess(restaurantId));
        },
      );
    } catch (e) {
      AppLogger.logError('Error creating restaurant', error: e);
      emit(const AdminError('Failed to create restaurant'));
    }
  }

  Future<void> updateRestaurantStatus(String restaurantId, bool isOpen) async {
    try {
      AppLogger.logInfo('Updating restaurant status: $restaurantId to $isOpen');

      final result = await repository.toggleRestaurantStatus(restaurantId, isOpen);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to update status', error: failure.message);
          emit(AdminError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Restaurant status updated');
          emit(RestaurantStatusUpdated());
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating restaurant status', error: e);
      emit(const AdminError('Failed to update restaurant status'));
    }
  }

  Future<void> updateRestaurant({
    required String restaurantId,
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    String? newPassword,
    required List<String> categories,
    required LatLng location,
    File? imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
  }) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Updating restaurant: $restaurantId');

      // Get existing restaurant first to preserve data
      final getResult = await repository.getRestaurantById(restaurantId);
      
      final existingRestaurant = getResult.fold(
        (failure) => null,
        (restaurant) => restaurant,
      );

      if (existingRestaurant == null) {
        emit(const AdminError('Restaurant not found'));
        return;
      }

      // Update restaurant entity with new data
      final updatedRestaurant = RestaurantEntity(
        id: restaurantId,
        ownerId: existingRestaurant.ownerId,
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
        categories: categories,
        location: {'latitude': location.latitude, 'longitude': location.longitude},
        isOpen: existingRestaurant.isOpen, // Preserve existing status
        rating: existingRestaurant.rating, // Preserve rating
        totalReviews: existingRestaurant.totalReviews, // Preserve reviews
        deliveryFee: deliveryFee,
        minOrderAmount: minOrderAmount,
        estimatedDeliveryTime: estimatedDeliveryTime,
        commercialRegistrationPhotoUrl: existingRestaurant.commercialRegistrationPhotoUrl,
        createdAt: existingRestaurant.createdAt, // Preserve creation date
      );

      final result = await repository.updateRestaurant(updatedRestaurant);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to update restaurant', error: failure.message);
          emit(AdminError(failure.message));
        },
        (_) async {
          // Update password if provided
          if (newPassword != null && newPassword.isNotEmpty) {
            final passwordResult = await repository.updateRestaurantPassword(
              restaurantId,
              newPassword,
            );
            
            passwordResult.fold(
              (failure) {
                AppLogger.logError('Failed to update password', error: failure.message);
                emit(AdminError('Restaurant updated but password update failed: ${failure.message}'));
                return;
              },
              (_) {
                AppLogger.logSuccess('Restaurant and password updated successfully');
                emit(RestaurantUpdatedSuccess());
              },
            );
          } else {
            AppLogger.logSuccess('Restaurant updated successfully');
            emit(RestaurantUpdatedSuccess());
          }
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating restaurant', error: e);
      emit(AdminError('Failed to update restaurant: $e'));
    }
  }

  Future<void> getRestaurantById(String restaurantId) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Fetching restaurant: $restaurantId');

      final result = await repository.getRestaurantById(restaurantId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to fetch restaurant', error: failure.message);
          emit(AdminError(failure.message));
        },
        (restaurant) {
          AppLogger.logSuccess('Restaurant fetched successfully');
          emit(RestaurantLoaded(restaurant));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching restaurant', error: e);
      emit(AdminError('Failed to fetch restaurant: $e'));
    }
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Deleting restaurant: $restaurantId');

      final result = await repository.deleteRestaurant(restaurantId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete restaurant', error: failure.message);
          emit(AdminError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Restaurant deleted successfully');
          emit(RestaurantDeletedSuccess());
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting restaurant', error: e);
      emit(const AdminError('Failed to delete restaurant'));
    }
  }
}

