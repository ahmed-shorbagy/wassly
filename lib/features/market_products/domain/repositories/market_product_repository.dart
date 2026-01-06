import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/market_product_entity.dart';

abstract class MarketProductRepository {
  /// Upload an image file
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  );

  /// Get all market products
  Future<Either<Failure, List<MarketProductEntity>>> getAllMarketProducts();

  /// Get market product by ID
  Future<Either<Failure, MarketProductEntity>> getMarketProductById(
    String productId,
  );

  /// Get market products by restaurant ID
  Future<Either<Failure, List<MarketProductEntity>>>
  getMarketProductsByRestaurantId(String restaurantId);

  /// Create a new market product
  Future<Either<Failure, MarketProductEntity>> createMarketProduct(
    MarketProductEntity product,
  );

  /// Update market product
  Future<Either<Failure, void>> updateMarketProduct(
    MarketProductEntity product,
  );

  /// Delete market product
  Future<Either<Failure, void>> deleteMarketProduct(String productId);

  /// Toggle market product availability
  Future<Either<Failure, void>> toggleMarketProductAvailability(
    String productId,
    bool isAvailable,
  );
}
