import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';
import '../../../restaurants/domain/entities/product_entity.dart';

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
    required List<String> categoryIds,
    required LatLng location,
    File? imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
  }) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Creating restaurant: $name');
      AppLogger.logInfo('Email: "$email"');
      AppLogger.logInfo('Password length: ${password.length}');

      final result = await repository.createRestaurant(
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
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to create restaurant',
            error: failure.message,
          );
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

      final result = await repository.toggleRestaurantStatus(
        restaurantId,
        isOpen,
      );

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

  Future<void> updateRestaurantDiscount(
    String restaurantId,
    bool hasDiscount,
  ) async {
    try {
      AppLogger.logInfo(
        'Updating restaurant discount: $restaurantId to $hasDiscount',
      );

      final result = await repository.toggleRestaurantDiscount(
        restaurantId,
        hasDiscount,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to update discount',
            error: failure.message,
          );
          emit(AdminError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Restaurant discount updated');
          emit(RestaurantStatusUpdated());
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating restaurant discount', error: e);
      emit(const AdminError('Failed to update restaurant discount'));
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
    required List<String> categoryIds,
    required LatLng location,
    File? imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
    bool hasDiscount = false,
    double? discountPercentage,
    String? discountDescription,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    File? discountImageFile,
    String? discountTargetProductId,
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

      // Handle Image Uploads
      String? imageUrl = existingRestaurant.imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          'restaurants',
          'profile',
        );
        uploadResult.fold(
          (failure) => AppLogger.logError(
            'Failed to upload profile image: ${failure.message}',
          ),
          (url) => imageUrl = url,
        );
      }

      String? commercialRegistrationPhotoUrl =
          existingRestaurant.commercialRegistrationPhotoUrl;
      if (commercialRegistrationPhotoFile != null) {
        final uploadResult = await repository.uploadImageFile(
          commercialRegistrationPhotoFile,
          'restaurants',
          'commercial_registration',
        );
        uploadResult.fold(
          (failure) => AppLogger.logError(
            'Failed to upload commercial registration: ${failure.message}',
          ),
          (url) => commercialRegistrationPhotoUrl = url,
        );
      }

      String? discountImageUrl = existingRestaurant.discountImageUrl;
      if (discountImageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          discountImageFile,
          'restaurants',
          'discount',
        );
        uploadResult.fold(
          (failure) => AppLogger.logError(
            'Failed to upload discount image: ${failure.message}',
          ),
          (url) => discountImageUrl = url,
        );
      }

      // Update restaurant entity with new data, preserving discount fields
      final updatedRestaurant = RestaurantEntity(
        id: restaurantId,
        ownerId: existingRestaurant.ownerId,
        name: name,
        description: description,
        address: address,
        phone: phone,
        email: email,
        categoryIds: categoryIds,
        location: {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
        isOpen: existingRestaurant.isOpen, // Preserve existing status
        rating: existingRestaurant.rating, // Preserve rating
        totalReviews: existingRestaurant.totalReviews, // Preserve reviews
        deliveryFee: deliveryFee,
        minOrderAmount: minOrderAmount,
        estimatedDeliveryTime: estimatedDeliveryTime,
        imageUrl: imageUrl, // Update image URL
        commercialRegistrationPhotoUrl: commercialRegistrationPhotoUrl,
        // Update discount fields from parameters
        hasDiscount: hasDiscount,
        discountPercentage: discountPercentage,
        discountDescription: discountDescription,
        discountStartDate: discountStartDate,
        discountEndDate: discountEndDate,
        discountImageUrl: discountImageUrl,
        discountTargetProductId: discountTargetProductId,
        createdAt: existingRestaurant.createdAt, // Preserve creation date
      );

      final result = await repository.updateRestaurant(updatedRestaurant);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to update restaurant',
            error: failure.message,
          );
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
                AppLogger.logError(
                  'Failed to update password',
                  error: failure.message,
                );
                emit(
                  AdminError(
                    'Restaurant updated but password update failed: ${failure.message}',
                  ),
                );
                return;
              },
              (_) {
                AppLogger.logSuccess(
                  'Restaurant and password updated successfully',
                );
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

  Future<void> getRestaurantProducts(String restaurantId) async {
    try {
      // Don't emit loading here to avoid disrupting the UI if it's already loaded
      // or if we want to load silently. But typically we want feedback.
      // Since this is likely called in initState, emitting loading might replace the current state
      // which might be RestaurantLoaded.
      // We should be careful.
      // If we emit AdminLoading, we lose RestaurantLoaded data in the UI (since UI checks state type).
      // Ideally, AdminState should be a single state with optional fields, but it's a sealed class hierarchy.
      // So we emit a separate AdminProductsLoaded state?
      // If we emit AdminProductsLoaded, we lose RestaurantLoaded!
      // This Cubit design is a bit limiting for multiple concurrent data types.
      // However, EditRestaurantScreen listens to state.
      // If we emit AdminProductsLoaded, the listener in EditRestaurantScreen handles it?
      // EditRestaurantScreen listener (line 401) handles RestaurantLoaded, RestaurantUpdatedSuccess, AdminError.
      // It DOES NOT handle AdminProductsLoaded yet.
      // I will add handling in UI.

      AppLogger.logInfo('Fetching products for restaurant: $restaurantId');

      final result = await repository.getRestaurantProducts(restaurantId);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch products',
            error: failure.message,
          );
          // Don't emit error to avoid blocking the main UI if products fail
        },
        (products) {
          AppLogger.logSuccess(
            'Products fetched successfully: ${products.length}',
          );
          emit(AdminProductsLoaded(products));
        },
      );
    } catch (e) {
      AppLogger.logError('Error fetching products', error: e);
    }
  }

  Future<void> getRestaurantById(String restaurantId) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Fetching restaurant: $restaurantId');

      final result = await repository.getRestaurantById(restaurantId);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to fetch restaurant',
            error: failure.message,
          );
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
          AppLogger.logError(
            'Failed to delete restaurant',
            error: failure.message,
          );
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

  Future<void> getPendingPartners() async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Fetching pending partners...');

      // Get users with isActive = false
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isActive', isEqualTo: false)
          .where('userType', whereIn: ['restaurant', 'market', 'driver'])
          .get();

      final List<Map<String, dynamic>> pending = [];

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userType = userData['userType'];
        final userId = userDoc.id;

        if (userType == 'restaurant' || userType == 'market') {
          final resSnapshot = await FirebaseFirestore.instance
              .collection('restaurants')
              .where('ownerId', isEqualTo: userId)
              .get();
          if (resSnapshot.docs.isNotEmpty) {
            pending.add({
              'user': userData,
              'details': resSnapshot.docs.first.data(),
              'id': resSnapshot.docs.first.id,
              'type': userType,
            });
          }
        } else if (userType == 'driver') {
          final driverSnapshot = await FirebaseFirestore.instance
              .collection('drivers')
              .where('userId', isEqualTo: userId)
              .get();
          if (driverSnapshot.docs.isNotEmpty) {
            pending.add({
              'user': userData,
              'details': driverSnapshot.docs.first.data(),
              'id': driverSnapshot.docs.first.id,
              'type': 'driver',
            });
          }
        }
      }

      emit(PendingPartnersLoaded(pending));
    } catch (e) {
      AppLogger.logError('Error fetching pending partners', error: e);
      emit(AdminError('Failed to fetch pending partners: $e'));
    }
  }

  Future<void> approvePartner(
    String userId,
    String detailId,
    String type,
  ) async {
    try {
      emit(AdminLoading());
      AppLogger.logInfo('Approving partner: $userId');

      // 1. Update user document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isActive': true,
      });

      // 2. Update detail document
      if (type == 'restaurant' || type == 'market') {
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(detailId)
            .update({'isApproved': true});
      } else if (type == 'driver') {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(detailId)
            .update({'isActive': true});
      }

      AppLogger.logSuccess('Partner approved successfully');
      emit(PartnerApprovedSuccess());
      // Refresh list
      getPendingPartners();
    } catch (e) {
      AppLogger.logError('Error approving partner', error: e);
      emit(AdminError('Failed to approve partner: $e'));
    }
  }

  void resetState() {
    emit(AdminInitial());
  }
}
