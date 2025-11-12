import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/restaurant_owner_repository.dart';
import '../models/restaurant_model.dart';
import '../models/product_model.dart';

class RestaurantOwnerRepositoryImpl implements RestaurantOwnerRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ImagePicker imagePicker;
  final SupabaseService supabaseService;

  RestaurantOwnerRepositoryImpl({
    required this.firestore,
    required this.storage,
    ImagePicker? imagePicker,
    SupabaseService? supabaseService,
  })  : imagePicker = imagePicker ?? ImagePicker(),
        supabaseService = supabaseService ?? SupabaseService();

  @override
  Future<Either<Failure, String>> uploadImage(
    String path,
    String fileName,
  ) async {
    try {
      AppLogger.logInfo('Uploading image to Supabase: $fileName');

      final file = File(path);
      
      // Upload to Supabase Storage
      final result = await supabaseService.uploadImage(
        file: file,
        bucketName: SupabaseConstants.restaurantImagesBucket,
        folder: SupabaseConstants.restaurantLogosFolder,
        fileName: fileName,
      );

      return result.fold(
        (failure) => Left(failure),
        (url) {
          AppLogger.logSuccess('Image uploaded to Supabase: $url');
          return Right(url);
        },
      );
    } catch (e) {
      AppLogger.logError('Error uploading image', error: e);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }
  
  @override
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  ) async {
    try {
      AppLogger.logInfo('Uploading image file to Supabase bucket: $bucketName');

      final result = await supabaseService.uploadImage(
        file: file,
        bucketName: bucketName,
        folder: folder,
      );

      return result;
    } catch (e) {
      AppLogger.logError('Error uploading image file', error: e);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, XFile?>> pickImage(ImageSource source) async {
    try {
      AppLogger.logInfo('Picking image from $source');

      final image = await imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        AppLogger.logSuccess('Image picked: ${image.path}');
      }

      return Right(image);
    } catch (e) {
      AppLogger.logError('Error picking image', error: e);
      return Left(CacheFailure('Failed to pick image'));
    }
  }

  @override
  Future<Either<Failure, String>> createRestaurant({
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
  }) async {
    try {
      AppLogger.logInfo('Creating restaurant: $name');

      // Upload image to Supabase first
      AppLogger.logInfo('Uploading restaurant image to Supabase...');
      final imageUploadResult = await uploadImageFile(
        imageFile,
        SupabaseConstants.restaurantImagesBucket,
        SupabaseConstants.restaurantLogosFolder,
      );

      String? imageUrl;
      imageUploadResult.fold(
        (failure) {
          AppLogger.logError('Failed to upload image', error: failure.message);
          throw Exception('Failed to upload image: ${failure.message}');
        },
        (url) {
          AppLogger.logSuccess('Image uploaded successfully');
          imageUrl = url;
        },
      );

      // Create restaurant document in Firestore
      AppLogger.logInfo('Creating restaurant document in Firestore...');
      final restaurantData = {
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'categories': categories,
        'location': GeoPoint(location.latitude, location.longitude),
        'imageUrl': imageUrl,
        'deliveryFee': deliveryFee,
        'minOrderAmount': minOrderAmount,
        'estimatedDeliveryTime': estimatedDeliveryTime,
        'isOpen': true,
        'rating': 0.0,
        'totalReviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await firestore.collection('restaurants').add(restaurantData);

      AppLogger.logSuccess('Restaurant created with ID: ${docRef.id}');
      return Right(docRef.id);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error creating restaurant', error: e);
      return Left(ServerFailure('Failed to create restaurant: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error creating restaurant', error: e);
      return Left(ServerFailure('Failed to create restaurant: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRestaurant(
    RestaurantEntity restaurant,
  ) async {
    try {
      AppLogger.logInfo('Updating restaurant: ${restaurant.id}');

      final model = RestaurantModel.fromEntity(restaurant);
      await firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Restaurant updated: ${restaurant.id}');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating restaurant', error: e);
      return Left(ServerFailure('Failed to update restaurant: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating restaurant', error: e);
      return Left(ServerFailure('Failed to update restaurant'));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantByOwnerId(
    String ownerId,
  ) async {
    try {
      AppLogger.logInfo('Fetching restaurant for owner: $ownerId');

      final snapshot = await firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        AppLogger.logWarning('No restaurant found for owner: $ownerId');
        return Left(CacheFailure('No restaurant found'));
      }

      final restaurant = RestaurantModel.fromFirestore(snapshot.docs.first);
      AppLogger.logSuccess('Restaurant fetched for owner');
      return Right(restaurant);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching restaurant', error: e);
      return Left(ServerFailure('Failed to fetch restaurant: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching restaurant', error: e);
      return Left(ServerFailure('Failed to fetch restaurant'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleRestaurantStatus(
    String restaurantId,
    bool isOpen,
  ) async {
    try {
      AppLogger.logInfo('Toggling restaurant status: $restaurantId to $isOpen');

      await firestore.collection('restaurants').doc(restaurantId).update({
        'isOpen': isOpen,
      });

      AppLogger.logSuccess('Restaurant status updated');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating restaurant status', error: e);
      return Left(ServerFailure('Failed to update status: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating restaurant status', error: e);
      return Left(ServerFailure('Failed to update restaurant status'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId) async {
    try {
      AppLogger.logInfo('Deleting restaurant: $restaurantId');

      // Delete all products associated with this restaurant
      final productsSnapshot = await firestore
          .collection('products')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the restaurant
      await firestore.collection('restaurants').doc(restaurantId).delete();

      AppLogger.logSuccess('Restaurant deleted: $restaurantId');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error deleting restaurant', error: e);
      return Left(ServerFailure('Failed to delete restaurant: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error deleting restaurant', error: e);
      return Left(ServerFailure('Failed to delete restaurant'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(
    ProductEntity product,
  ) async {
    try {
      AppLogger.logInfo('Adding product: ${product.name}');

      final model = ProductModel.fromEntity(product);
      final docRef = await firestore.collection('products').add(
            model.toFirestore(),
          );

      final createdProduct = ProductEntity(
        id: docRef.id,
        restaurantId: product.restaurantId,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        isAvailable: product.isAvailable,
        createdAt: product.createdAt,
      );

      AppLogger.logSuccess('Product added: ${docRef.id}');
      return Right(createdProduct);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error adding product', error: e);
      return Left(ServerFailure('Failed to add product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error adding product', error: e);
      return Left(ServerFailure('Failed to add product'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(ProductEntity product) async {
    try {
      AppLogger.logInfo('Updating product: ${product.id}');

      final model = ProductModel.fromEntity(product);
      await firestore
          .collection('products')
          .doc(product.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Product updated: ${product.id}');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating product', error: e);
      return Left(ServerFailure('Failed to update product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating product', error: e);
      return Left(ServerFailure('Failed to update product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      AppLogger.logInfo('Deleting product: $productId');

      await firestore.collection('products').doc(productId).delete();

      AppLogger.logSuccess('Product deleted: $productId');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error deleting product', error: e);
      return Left(ServerFailure('Failed to delete product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error deleting product', error: e);
      return Left(ServerFailure('Failed to delete product'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      AppLogger.logInfo('Toggling product availability: $productId');

      await firestore.collection('products').doc(productId).update({
        'isAvailable': isAvailable,
      });

      AppLogger.logSuccess('Product availability updated');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating availability', error: e);
      return Left(ServerFailure('Failed to update availability: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating availability', error: e);
      return Left(ServerFailure('Failed to update availability'));
    }
  }
}

