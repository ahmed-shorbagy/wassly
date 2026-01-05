import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/supabase_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/restaurant_owner_repository.dart';
import '../models/restaurant_model.dart';
import '../models/product_model.dart';

class RestaurantOwnerRepositoryImpl implements RestaurantOwnerRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth firebaseAuth;
  final ImagePicker imagePicker;
  final SupabaseService supabaseService;

  RestaurantOwnerRepositoryImpl({
    required this.firestore,
    required this.storage,
    FirebaseAuth? firebaseAuth,
    ImagePicker? imagePicker,
    SupabaseService? supabaseService,
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       imagePicker = imagePicker ?? ImagePicker(),
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

      return result.fold((failure) => Left(failure), (url) {
        AppLogger.logSuccess('Image uploaded to Supabase: $url');
        return Right(url);
      });
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
    required String password,
    required List<String> categoryIds,
    required LatLng location,
    required File imageFile,
    required double deliveryFee,
    required double minOrderAmount,
    required int estimatedDeliveryTime,
    File? commercialRegistrationPhotoFile,
  }) async {
    try {
      AppLogger.logInfo('Creating restaurant: $name');

      // Create Firebase Auth user account first
      AppLogger.logInfo('Creating Firebase Auth user account...');
      UserCredential? userCredential;
      try {
        userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        AppLogger.logSuccess(
          'Firebase Auth user created: ${userCredential.user?.uid}',
        );
      } on FirebaseAuthException catch (e) {
        AppLogger.logError('Failed to create Firebase Auth user', error: e);
        return Left(
          ServerFailure('Failed to create user account: ${e.message}'),
        );
      }

      if (userCredential.user == null) {
        AppLogger.logError('User credential is null after creation');
        return const Left(ServerFailure('Failed to create user account'));
      }

      final userId = userCredential.user!.uid;

      // Create user document in users collection
      AppLogger.logInfo('Creating user document in Firestore...');
      try {
        // Store password temporarily for admin updates (in production, encrypt this)
        // This allows admin to update password later
        await firestore.collection(AppConstants.usersCollection).doc(userId).set({
          'id': userId,
          'email': email,
          'name': name,
          'phone': phone,
          'userType': AppConstants.userTypeRestaurant,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'tempPassword':
              password, // Temporary storage for admin password updates
          // Note: In production, encrypt this field or use Cloud Function with Admin SDK
        });
        AppLogger.logSuccess('User document created');
      } catch (e) {
        // If user document creation fails, delete the auth user
        await userCredential.user?.delete();
        AppLogger.logError('Failed to create user document', error: e);
        return Left(ServerFailure('Failed to create user document: $e'));
      }

      // Upload restaurant image to Supabase
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

      // Upload commercial registration photo if provided
      String? commercialRegistrationPhotoUrl;
      if (commercialRegistrationPhotoFile != null) {
        AppLogger.logInfo(
          'Uploading commercial registration photo to Supabase...',
        );
        final commercialRegUploadResult = await uploadImageFile(
          commercialRegistrationPhotoFile,
          SupabaseConstants.restaurantImagesBucket,
          'commercial_registrations',
        );

        commercialRegUploadResult.fold(
          (failure) {
            AppLogger.logError(
              'Failed to upload commercial registration photo',
              error: failure.message,
            );
            throw Exception(
              'Failed to upload commercial registration photo: ${failure.message}',
            );
          },
          (url) {
            AppLogger.logSuccess(
              'Commercial registration photo uploaded successfully',
            );
            commercialRegistrationPhotoUrl = url;
          },
        );
      }

      // Create restaurant document in Firestore
      AppLogger.logInfo('Creating restaurant document in Firestore...');
      final restaurantData = {
        'id': '', // Will be set by document ID
        'ownerId': userId, // Link restaurant to user account
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'categoryIds': categoryIds,
        'location': GeoPoint(location.latitude, location.longitude),
        'imageUrl': imageUrl,
        'deliveryFee': deliveryFee,
        'minOrderAmount': minOrderAmount,
        'estimatedDeliveryTime': estimatedDeliveryTime,
        'isOpen': true,
        'rating': 0.0,
        'totalReviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        if (commercialRegistrationPhotoUrl != null)
          'commercialRegistrationPhotoUrl': commercialRegistrationPhotoUrl,
      };

      final docRef = await firestore
          .collection('restaurants')
          .add(restaurantData);

      // Update restaurant document with its ID
      await docRef.update({'id': docRef.id});

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
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(
    String restaurantId,
  ) async {
    try {
      AppLogger.logInfo('Fetching restaurant by ID: $restaurantId');

      final doc = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!doc.exists) {
        AppLogger.logWarning('Restaurant not found: $restaurantId');
        return const Left(CacheFailure('Restaurant not found'));
      }

      final restaurant = RestaurantModel.fromFirestore(doc);
      AppLogger.logSuccess('Restaurant fetched by ID');
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
  Future<Either<Failure, void>> toggleRestaurantDiscount(
    String restaurantId,
    bool hasDiscount,
  ) async {
    try {
      AppLogger.logInfo(
        'Toggling restaurant discount: $restaurantId to $hasDiscount',
      );

      await firestore.collection('restaurants').doc(restaurantId).update({
        'hasDiscount': hasDiscount,
      });

      AppLogger.logSuccess('Restaurant discount updated');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        'Firebase error updating restaurant discount',
        error: e,
      );
      return Left(ServerFailure('Failed to update discount: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating restaurant discount', error: e);
      return Left(ServerFailure('Failed to update restaurant discount'));
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
      final docRef = await firestore
          .collection('products')
          .add(model.toFirestore());

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
      final updateData = model.toFirestore();
      // Ensure 'id' field is not included in update (document ID is the ID)
      updateData.remove('id');

      await firestore.collection('products').doc(product.id).update(updateData);

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

  @override
  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(
    String restaurantId,
  ) async {
    try {
      AppLogger.logInfo('Fetching products for restaurant: $restaurantId');

      final snapshot = await firestore
          .collection('products')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      AppLogger.logSuccess('Products fetched: ${products.length}');
      return Right(products);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching products', error: e);
      return Left(ServerFailure('Failed to fetch products: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching products', error: e);
      return Left(ServerFailure('Failed to fetch products'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRestaurantPassword(
    String restaurantId,
    String newPassword,
  ) async {
    try {
      AppLogger.logInfo('Updating password for restaurant: $restaurantId');

      // Get restaurant to find ownerId and email
      final restaurantDoc = await firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!restaurantDoc.exists) {
        return const Left(ServerFailure('Restaurant not found'));
      }

      final restaurantData = restaurantDoc.data()!;
      final ownerId = restaurantData['ownerId'] as String?;
      final email = restaurantData['email'] as String?;

      if (ownerId == null || ownerId.isEmpty) {
        return const Left(ServerFailure('Restaurant owner ID not found'));
      }

      if (email == null || email.isEmpty) {
        return const Left(ServerFailure('Restaurant email not found'));
      }

      // Save current admin user to restore session later
      final currentAdminUser = firebaseAuth.currentUser;
      final adminEmail = currentAdminUser?.email;

      // Check if we have a stored password in Firestore for this user
      // This is a workaround - in production, use Firebase Admin SDK or Cloud Function
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(ownerId)
          .get();

      if (!userDoc.exists) {
        return const Left(ServerFailure('User account not found'));
      }

      // Get stored password to sign in temporarily
      final storedPassword = userDoc.data()?['tempPassword'] as String?;

      if (storedPassword == null || storedPassword.isEmpty) {
        return const Left(
          ServerFailure(
            'Password not found. Cannot update password without stored password.',
          ),
        );
      }

      try {
        // Sign in as the restaurant user temporarily
        AppLogger.logInfo(
          'Signing in as restaurant user to update password...',
        );
        final restaurantCredential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: storedPassword);

        if (restaurantCredential.user == null) {
          return const Left(
            ServerFailure('Failed to sign in as restaurant user'),
          );
        }

        // Update password
        AppLogger.logInfo('Updating password...');
        await restaurantCredential.user!.updatePassword(newPassword);
        AppLogger.logSuccess('Password updated successfully');

        // Update stored password in Firestore
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(ownerId)
            .update({
              'tempPassword': newPassword, // Update stored password
              'lastPasswordUpdate': FieldValue.serverTimestamp(),
            });

        // Sign out restaurant user
        await firebaseAuth.signOut();

        // Note: Admin session was lost - admin will need to sign in again
        // In production, implement session preservation or Cloud Function
        if (adminEmail != null) {
          AppLogger.logInfo('Admin session ended. Please sign in again.');
        }

        AppLogger.logSuccess('Password updated successfully');
        return const Right(null);
      } on FirebaseAuthException catch (e) {
        AppLogger.logError('Firebase Auth error updating password', error: e);

        // Try to restore admin session if possible
        if (currentAdminUser != null && adminEmail != null) {
          // Can't automatically restore, but log for manual restoration
          AppLogger.logInfo('Please sign in as admin again');
        }

        return Left(ServerFailure('Failed to update password: ${e.message}'));
      } catch (e) {
        AppLogger.logError('Error updating password', error: e);

        // Try to restore admin session
        if (currentAdminUser != null && adminEmail != null) {
          AppLogger.logInfo('Please sign in as admin again');
        }

        return Left(ServerFailure('Failed to update password: $e'));
      }
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating password', error: e);
      return Left(ServerFailure('Failed to update password: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating password', error: e);
      return Left(ServerFailure('Failed to update password: $e'));
    }
  }
}
