import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';

part 'admin_product_state.dart';

class AdminProductCubit extends Cubit<AdminProductState> {
  final RestaurantOwnerRepository repository;

  AdminProductCubit({required this.repository}) : super(AdminProductInitial());

  Future<void> loadRestaurantProducts(String restaurantId) async {
    try {
      emit(AdminProductLoading());
      AppLogger.logInfo('Loading products for restaurant: $restaurantId');

      final result = await repository.getRestaurantProducts(restaurantId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to load products', error: failure.message);
          emit(AdminProductError(failure.message));
        },
        (products) {
          AppLogger.logSuccess('Products loaded: ${products.length}');
          emit(AdminProductLoaded(products));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading products', error: e);
      emit(AdminProductError('Failed to load products: $e'));
    }
  }

  Future<void> addProduct({
    required String restaurantId,
    required String name,
    required String description,
    required double price,
    String? categoryId,
    String? category, // Keep for backward compatibility
    required File? imageFile,
    bool isAvailable = true,
  }) async {
    try {
      emit(AdminProductLoading());
      AppLogger.logInfo('Adding product: $name');

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'products',
        );

        uploadResult.fold(
          (failure) {
            AppLogger.logError(
              'Failed to upload image',
              error: failure.message,
            );
            emit(
              AdminProductError('Failed to upload image: ${failure.message}'),
            );
            return;
          },
          (url) {
            AppLogger.logSuccess('Image uploaded successfully');
            imageUrl = url;
          },
        );

        if (imageUrl == null) return; // Upload failed, already emitted error
      }

      // Create product entity
      final product = ProductEntity(
        id: '', // Will be set by repository
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
        category: category, // Keep for backward compatibility
        isAvailable: isAvailable,
        createdAt: DateTime.now(),
      );

      final result = await repository.addProduct(product);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to add product', error: failure.message);
          emit(AdminProductError(failure.message));
        },
        (addedProduct) {
          AppLogger.logSuccess('Product added successfully');
          emit(AdminProductAdded());
          // Reload products
          loadRestaurantProducts(restaurantId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error adding product', error: e);
      emit(AdminProductError('Failed to add product: $e'));
    }
  }

  Future<void> updateProduct({
    required ProductEntity product,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? category, // Keep for backward compatibility
    File? imageFile,
    bool? isAvailable,
  }) async {
    try {
      emit(AdminProductLoading());
      AppLogger.logInfo('Updating product: ${product.id}');

      // Upload new image if provided
      String? imageUrl = product.imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'products',
        );

        uploadResult.fold(
          (failure) {
            AppLogger.logError(
              'Failed to upload image',
              error: failure.message,
            );
            emit(
              AdminProductError('Failed to upload image: ${failure.message}'),
            );
            return;
          },
          (url) {
            AppLogger.logSuccess('Image uploaded successfully');
            imageUrl = url;
          },
        );

        if (imageUrl == null) return; // Upload failed
      }

      // Update product entity
      final updatedProduct = ProductEntity(
        id: product.id,
        restaurantId: product.restaurantId,
        name: name ?? product.name,
        description: description ?? product.description,
        price: price ?? product.price,
        imageUrl: imageUrl,
        categoryId: categoryId ?? product.categoryId,
        category:
            category ?? product.category, // Keep for backward compatibility
        isAvailable: isAvailable ?? product.isAvailable,
        createdAt: product.createdAt,
      );

      final result = await repository.updateProduct(updatedProduct);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to update product',
            error: failure.message,
          );
          emit(AdminProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Product updated successfully');
          emit(AdminProductUpdated());
          // Reload products
          loadRestaurantProducts(product.restaurantId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating product', error: e);
      emit(AdminProductError('Failed to update product: $e'));
    }
  }

  Future<void> deleteProduct(String productId, String restaurantId) async {
    try {
      emit(AdminProductLoading());
      AppLogger.logInfo('Deleting product: $productId');

      final result = await repository.deleteProduct(productId);

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to delete product',
            error: failure.message,
          );
          emit(AdminProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Product deleted successfully');
          emit(AdminProductDeleted());
          // Reload products
          loadRestaurantProducts(restaurantId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting product', error: e);
      emit(AdminProductError('Failed to delete product: $e'));
    }
  }

  Future<void> toggleProductAvailability(
    String productId,
    bool isAvailable,
    String restaurantId,
  ) async {
    try {
      AppLogger.logInfo('Toggling product availability: $productId');

      final result = await repository.toggleProductAvailability(
        productId,
        isAvailable,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to toggle availability',
            error: failure.message,
          );
          emit(AdminProductError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Product availability updated');
          // Reload products
          loadRestaurantProducts(restaurantId);
        },
      );
    } catch (e) {
      AppLogger.logError('Error toggling product availability', error: e);
      emit(AdminProductError('Failed to toggle product availability: $e'));
    }
  }

  void resetState() {
    emit(AdminProductInitial());
  }
}
