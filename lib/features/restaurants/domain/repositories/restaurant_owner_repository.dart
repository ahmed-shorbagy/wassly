import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../entities/restaurant_entity.dart';
import '../entities/product_entity.dart';

abstract class RestaurantOwnerRepository {
  /// Upload an image to Supabase Storage
  Future<Either<Failure, String>> uploadImage(String path, String fileName);

  /// Upload an image file directly to Supabase
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  );

  /// Pick an image from gallery or camera
  Future<Either<Failure, XFile?>> pickImage(ImageSource source);

  /// Create a new restaurant (Admin use)
  Future<Either<Failure, String>> createRestaurant({
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
    File?
    commercialRegistrationPhotoFile, // Optional photo file for commercial registration
  });

  /// Update restaurant information
  Future<Either<Failure, void>> updateRestaurant(RestaurantEntity restaurant);

  /// Update restaurant password
  Future<Either<Failure, void>> updateRestaurantPassword(
    String restaurantId,
    String newPassword,
  );

  /// Get restaurant by owner ID
  Future<Either<Failure, RestaurantEntity>> getRestaurantByOwnerId(
    String ownerId,
  );

  /// Get restaurant by restaurant ID
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(
    String restaurantId,
  );

  /// Toggle restaurant status (open/closed)
  Future<Either<Failure, void>> toggleRestaurantStatus(
    String restaurantId,
    bool isOpen,
  );

  /// Toggle restaurant discount (enable/disable)
  Future<Either<Failure, void>> toggleRestaurantDiscount(
    String restaurantId,
    bool hasDiscount,
  );

  /// Delete restaurant
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId);

  /// Add a new product to the restaurant
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);

  /// Update product information
  Future<Either<Failure, void>> updateProduct(ProductEntity product);

  /// Delete a product
  Future<Either<Failure, void>> deleteProduct(String productId);

  /// Toggle product availability
  Future<Either<Failure, void>> toggleProductAvailability(
    String productId,
    bool isAvailable,
  );

  /// Get all products for a restaurant
  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(
    String restaurantId,
  );
}
