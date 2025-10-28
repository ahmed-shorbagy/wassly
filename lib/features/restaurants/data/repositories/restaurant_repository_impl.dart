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
        final snapshot = await firestore
            .collection(AppConstants.productsCollection)
            .where('restaurantId', isEqualTo: restaurantId)
            .where('isAvailable', isEqualTo: true)
            .get();

        final products = snapshot.docs
            .map((doc) => ProductModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList();

        return Right(products);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Failed to load products'));
      }
    } else {
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
