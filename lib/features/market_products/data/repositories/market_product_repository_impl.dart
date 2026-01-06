import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../domain/entities/market_product_entity.dart';
import '../../domain/repositories/market_product_repository.dart';
import '../models/market_product_model.dart';

class MarketProductRepositoryImpl implements MarketProductRepository {
  final FirebaseFirestore firestore;
  final ImageUploadHelper imageUploadHelper;

  MarketProductRepositoryImpl({
    required this.firestore,
    required this.imageUploadHelper,
  });

  @override
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  ) async {
    try {
      AppLogger.logInfo('Uploading image to $bucketName/$folder');
      final result = await imageUploadHelper.uploadFile(
        file: file,
        bucketName: bucketName,
        folder: folder,
      );
      return result.fold((failure) => Left(failure), (url) {
        AppLogger.logSuccess('Image uploaded successfully');
        return Right(url);
      });
    } catch (e) {
      AppLogger.logError('Error uploading image', error: e);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MarketProductEntity>>>
  getAllMarketProducts() async {
    try {
      AppLogger.logInfo('Fetching all market products');

      final snapshot = await firestore
          .collection('market_products')
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => MarketProductModel.fromFirestore(doc))
          .toList();

      AppLogger.logSuccess('Fetched ${products.length} market products');
      return Right(products);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching market products', error: e);
      return Left(ServerFailure('Failed to fetch products: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching market products', error: e);
      return Left(ServerFailure('Failed to fetch products'));
    }
  }

  @override
  Future<Either<Failure, MarketProductEntity>> getMarketProductById(
    String productId,
  ) async {
    try {
      AppLogger.logInfo('Fetching market product: $productId');

      final doc = await firestore
          .collection('market_products')
          .doc(productId)
          .get();

      if (!doc.exists) {
        AppLogger.logWarning('Market product not found: $productId');
        return const Left(CacheFailure('Product not found'));
      }

      final product = MarketProductModel.fromFirestore(doc);
      AppLogger.logSuccess('Market product fetched successfully');
      return Right(product);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error fetching market product', error: e);
      return Left(ServerFailure('Failed to fetch product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error fetching market product', error: e);
      return Left(ServerFailure('Failed to fetch product'));
    }
  }

  @override
  Future<Either<Failure, List<MarketProductEntity>>>
  getMarketProductsByRestaurantId(String restaurantId) async {
    try {
      AppLogger.logInfo(
        'Fetching market products for restaurant: $restaurantId',
      );

      final snapshot = await firestore
          .collection('market_products')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => MarketProductModel.fromFirestore(doc))
          .toList();

      AppLogger.logSuccess(
        'Fetched ${products.length} market products for restaurant: $restaurantId',
      );
      return Right(products);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        'Firebase error fetching market products for restaurant',
        error: e,
      );
      return Left(ServerFailure('Failed to fetch products: ${e.message}'));
    } catch (e) {
      AppLogger.logError(
        'Error fetching market products for restaurant',
        error: e,
      );
      return Left(ServerFailure('Failed to fetch products'));
    }
  }

  @override
  Future<Either<Failure, MarketProductEntity>> createMarketProduct(
    MarketProductEntity product,
  ) async {
    try {
      AppLogger.logInfo('Creating market product: ${product.name}');

      final model = MarketProductModel.fromEntity(product);
      final docRef = await firestore
          .collection('market_products')
          .add(model.toFirestore());

      final createdProduct = MarketProductModel(
        id: docRef.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        isAvailable: product.isAvailable,
        restaurantId: product.restaurantId,
        createdAt: product.createdAt,
        updatedAt: product.updatedAt,
      );

      AppLogger.logSuccess('Market product created: ${docRef.id}');
      return Right(createdProduct);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error creating market product', error: e);
      return Left(ServerFailure('Failed to create product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error creating market product', error: e);
      return Left(ServerFailure('Failed to create product'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMarketProduct(
    MarketProductEntity product,
  ) async {
    try {
      AppLogger.logInfo('Updating market product: ${product.id}');

      final model = MarketProductModel.fromEntity(product);
      await firestore
          .collection('market_products')
          .doc(product.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Market product updated: ${product.id}');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error updating market product', error: e);
      return Left(ServerFailure('Failed to update product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error updating market product', error: e);
      return Left(ServerFailure('Failed to update product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMarketProduct(String productId) async {
    try {
      AppLogger.logInfo('Deleting market product: $productId');

      await firestore.collection('market_products').doc(productId).delete();

      AppLogger.logSuccess('Market product deleted: $productId');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError('Firebase error deleting market product', error: e);
      return Left(ServerFailure('Failed to delete product: ${e.message}'));
    } catch (e) {
      AppLogger.logError('Error deleting market product', error: e);
      return Left(ServerFailure('Failed to delete product'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMarketProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    try {
      AppLogger.logInfo('Toggling market product availability: $productId');

      await firestore.collection('market_products').doc(productId).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.logSuccess('Market product availability updated');
      return const Right(null);
    } on FirebaseException catch (e) {
      AppLogger.logError(
        'Firebase error updating market product availability',
        error: e,
      );
      return Left(ServerFailure('Failed to update availability: ${e.message}'));
    } catch (e) {
      AppLogger.logError(
        'Error updating market product availability',
        error: e,
      );
      return Left(ServerFailure('Failed to update availability'));
    }
  }
}
