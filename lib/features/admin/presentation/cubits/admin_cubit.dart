import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
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
    required List<String> categories,
    required LatLng location,
    required File imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    String? commercialRegistration,
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
        categories: categories,
        location: location,
        imageFile: imageFile,
        deliveryFee: deliveryFee,
        minOrderAmount: minOrderAmount,
        estimatedDeliveryTime: estimatedDeliveryTime,
        commercialRegistration: commercialRegistration,
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

