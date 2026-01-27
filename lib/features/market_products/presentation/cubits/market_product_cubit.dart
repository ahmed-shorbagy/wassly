import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/market_product_entity.dart';
import '../../domain/repositories/market_product_repository.dart';

part 'market_product_state.dart';

class MarketProductCubit extends Cubit<MarketProductState> {
  final MarketProductRepository repository;

  MarketProductCubit({required this.repository})
    : super(MarketProductInitial());

  Future<void> loadAllMarketProducts() async {
    try {
      emit(MarketProductLoading());
      AppLogger.logInfo('Loading all market products');

      final result = await repository.getAllMarketProducts();

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to load market products',
            error: failure.message,
          );
          emit(MarketProductError(failure.message));
        },
        (products) {
          AppLogger.logSuccess('Market products loaded: ${products.length}');
          emit(MarketProductLoaded(products));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading market products', error: e);
      emit(MarketProductError('Failed to load market products: $e'));
    }
  }

  Future<void> addMarketProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required File? imageFile,
    bool isAvailable = true,
  }) async {
    try {
      emit(MarketProductLoading());
      AppLogger.logInfo('Adding market product: $name');

      String? imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.productImagesBucket,
          'market_products',
        );
        final result = uploadResult.fold((failure) {
          emit(
            MarketProductError('Failed to upload image: ${failure.message}'),
          );
          return null as String?;
        }, (url) => url);
        if (result == null) return;
        imageUrl = result;
      }

      final product = MarketProductEntity(
        id: '', // Will be set by repository
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isAvailable: isAvailable,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createMarketProduct(product);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to add market product',
            error: failure.message,
          );
          emit(MarketProductError(failure.message));
        },
        (createdProduct) {
          AppLogger.logSuccess('Market product added: ${createdProduct.id}');
          emit(MarketProductAdded(createdProduct));
          loadAllMarketProducts(); // Reload list
        },
      );
    } catch (e) {
      AppLogger.logError('Error adding market product', error: e);
      emit(MarketProductError('Failed to add market product: $e'));
    }
  }

  Future<void> updateMarketProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    File? imageFile,
    bool? isAvailable,
  }) async {
    try {
      emit(MarketProductLoading());
      AppLogger.logInfo('Updating market product: $productId');

      // Get existing product to preserve image if not updating
      final existingResult = await repository.getMarketProductById(productId);
      String? imageUrl;

      existingResult.fold(
        (failure) {
          emit(MarketProductError('Failed to get existing product'));
          return;
        },
        (existingProduct) {
          imageUrl = existingProduct.imageUrl;
        },
      );

      // Upload new image if provided
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.productImagesBucket,
          'market_products',
        );
        final result = uploadResult.fold((failure) {
          emit(
            MarketProductError('Failed to upload image: ${failure.message}'),
          );
          return null as String?;
        }, (url) => url);
        if (result == null) return;
        imageUrl = result;
      }

      final product = MarketProductEntity(
        id: productId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isAvailable: isAvailable ?? true,
        createdAt: DateTime.now(), // Will be preserved in repository
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateMarketProduct(product);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to update market product',
            error: failure.message,
          );
          emit(MarketProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Market product updated: $productId');
          emit(MarketProductUpdated());
          loadAllMarketProducts(); // Reload list
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating market product', error: e);
      emit(MarketProductError('Failed to update market product: $e'));
    }
  }

  Future<void> deleteMarketProduct(String productId) async {
    try {
      emit(MarketProductLoading());
      AppLogger.logInfo('Deleting market product: $productId');

      final result = await repository.deleteMarketProduct(productId);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to delete market product',
            error: failure.message,
          );
          emit(MarketProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Market product deleted: $productId');
          emit(MarketProductDeleted());
          loadAllMarketProducts(); // Reload list
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting market product', error: e);
      emit(MarketProductError('Failed to delete market product: $e'));
    }
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      AppLogger.logInfo('Toggling market product availability: $productId');

      final result = await repository.toggleMarketProductAvailability(
        productId,
        isAvailable,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to toggle availability',
            error: failure.message,
          );
          emit(MarketProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Market product availability updated');
          emit(MarketProductAvailabilityToggled());
          loadAllMarketProducts(); // Reload list
        },
      );
    } catch (e) {
      AppLogger.logError('Error toggling availability', error: e);
      emit(MarketProductError('Failed to update availability: $e'));
    }
  }

  void resetState() {
    emit(MarketProductInitial());
  }
}
