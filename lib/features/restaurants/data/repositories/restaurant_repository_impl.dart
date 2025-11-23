import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/restaurant_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../models/restaurant_model.dart';
import '../models/product_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  RestaurantRepositoryImpl({
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants() async {
    if (await networkInfo.isConnected) {
      try {
        // Get all restaurants, not just open ones
        final snapshot = await firestore
            .collection(AppConstants.restaurantsCollection)
            .get();

        AppLogger.logInfo(
          'Found ${snapshot.docs.length} restaurants in Firestore',
        );

        final restaurants = snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            AppLogger.logInfo(
              'Processing restaurant: ${data['name']} (ID: ${doc.id})',
            );
            return RestaurantModel.fromJson({'id': doc.id, ...data});
          } catch (e) {
            AppLogger.logError('Error parsing restaurant ${doc.id}', error: e);
            rethrow;
          }
        }).toList();

        AppLogger.logSuccess(
          'Successfully loaded ${restaurants.length} restaurants',
        );
        return Right(restaurants);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to load restaurants', error: e);
        return Left(
          ServerFailure('Failed to load restaurants: ${e.toString()}'),
        );
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final doc = await firestore
            .collection(AppConstants.restaurantsCollection)
            .doc(id)
            .get();

        if (doc.exists) {
          final restaurant = RestaurantModel.fromJson({
            'id': doc.id,
            ...doc.data()!,
          });
          return Right(restaurant);
        } else {
          return const Left(ServerFailure('Restaurant not found'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Failed to load restaurant'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRestaurantProducts(
    String restaurantId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        AppLogger.logInfo('Fetching products from Firestore for restaurant: $restaurantId');
        
        // First try to get all products for the restaurant
        final snapshot = await firestore
            .collection(AppConstants.productsCollection)
            .where('restaurantId', isEqualTo: restaurantId)
            .get();

        AppLogger.logInfo('Found ${snapshot.docs.length} total products in Firestore for restaurant');

        // Filter products in memory to include:
        // 1. Products with isAvailable == true
        // 2. Products where isAvailable is null or missing (treat as available)
        final products = snapshot.docs
            .map((doc) {
              try {
                // Ensure document has a valid ID
                if (doc.id.isEmpty) {
                  AppLogger.logWarning('Skipping product with empty document ID');
                  return null;
                }
                
                final data = doc.data();
                final isAvailable = data['isAvailable'];
                // Include product if isAvailable is true, null, or missing
                if (isAvailable == false) {
                  return null; // Skip unavailable products
                }
                
                // Remove 'id' from data if it exists, then set it to doc.id
                // This ensures the document ID is always used, not any id in the data
                final cleanData = Map<String, dynamic>.from(data);
                cleanData.remove('id'); // Remove any existing id field
                cleanData['id'] = doc.id; // Set the document ID
                
                final product = ProductModel.fromJson(cleanData);
                
                // Double-check that product has valid ID after parsing
                if (product.id.isEmpty) {
                  AppLogger.logWarning('Skipping product with empty ID after parsing: ${doc.id}');
                  return null;
                }
                
                return product;
              } catch (e) {
                AppLogger.logError('Error parsing product ${doc.id}', error: e);
                return null;
              }
            })
            .where((product) => product != null && product.id.isNotEmpty)
            .cast<ProductEntity>()
            .toList();

        AppLogger.logSuccess('Successfully loaded ${products.length} available products');
        return Right(products);
      } on ServerException catch (e) {
        AppLogger.logError('Server exception loading products', error: e.message);
        return Left(ServerFailure(e.message));
      } catch (e) {
        AppLogger.logError('Failed to load products', error: e);
        return Left(ServerFailure('Failed to load products: ${e.toString()}'));
      }
    } else {
      AppLogger.logError('No internet connection when loading products');
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    String productId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final doc = await firestore
            .collection(AppConstants.productsCollection)
            .doc(productId)
            .get();

        if (doc.exists) {
          final product = ProductModel.fromJson({'id': doc.id, ...doc.data()!});
          return Right(product);
        } else {
          return const Left(ServerFailure('Product not found'));
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Failed to load product'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
