import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../../../core/services/toast_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/logger.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  final FirebaseAuth firebaseAuth;

  CartCubit({required this.repository, required this.firebaseAuth})
    : super(CartInitial()) {
    loadCart();
  }

  String? get _userId => firebaseAuth.currentUser?.uid;

  StreamSubscription<List<CartItemEntity>>? _cartSubscription;

  void loadCart() {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    // Cancel existing subscription if any
    _cartSubscription?.cancel();

    emit(CartLoading());

    _cartSubscription = repository
        .getCartStream(userId)
        .listen(
          (items) {
            if (isClosed) return;

            AppLogger.logInfo(
              'Cart stream update: received ${items.length} items',
            );

            // Filter out invalid items (products without IDs)
            final validItems = items
                .where(
                  (item) =>
                      item.product.id.isNotEmpty &&
                      item.product.restaurantId.isNotEmpty &&
                      item.quantity > 0,
                )
                .toList();

            AppLogger.logInfo('Valid items count: ${validItems.length}');
            for (var item in validItems) {
              AppLogger.logInfo(
                'Item: ${item.product.name}, Quantity: ${item.quantity}, Price: ${item.product.price}, RestID: ${item.product.restaurantId}',
              );
            }

            // Validate all items belong to the same restaurant
            String? restaurantId;
            if (validItems.isNotEmpty) {
              restaurantId = validItems.first.product.restaurantId;

              // Check if all items belong to the same restaurant
              final allSameRestaurant = validItems.every(
                (item) => item.product.restaurantId == restaurantId,
              );

              if (!allSameRestaurant) {
                AppLogger.logWarning(
                  'Items from different restaurants detected',
                );
                // If items from different restaurants, keep only items from first restaurant
                final filteredItems = validItems
                    .where((item) => item.product.restaurantId == restaurantId)
                    .toList();

                if (filteredItems.isNotEmpty) {
                  // Remove items from other restaurants automatically
                  _removeItemsFromOtherRestaurants(
                    userId,
                    restaurantId,
                    validItems,
                  );
                  emit(CartLoaded(filteredItems, restaurantId: restaurantId));
                  return;
                } else {
                  // No valid items from first restaurant, clear cart
                  clearCart();
                  return;
                }
              }
            }

            emit(CartLoaded(validItems, restaurantId: restaurantId));
          },
          onError: (error) {
            if (isClosed) return;
            AppLogger.logError('Failed to load cart', error: error);
            emit(CartError('Failed to load cart: ${error.toString()}'));
          },
        );
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }

  Future<void> addItem(
    ProductEntity product, {
    int quantity = 1,
    BuildContext? context,
  }) async {
    final userId = _userId;
    if (userId == null) {
      // Try to get localization from context if available
      String message = 'Please login to continue';
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        message = l10n?.pleaseLoginToContinue ?? message;
      }
      ToastService.showError(message);
      return;
    }

    // Validate product ID - this is critical
    if (product.id.isEmpty || product.id.trim().isEmpty) {
      String message = 'Invalid product. Please try again.';
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        message = l10n?.invalidProduct ?? message;
      }
      ToastService.showError(message);
      return;
    }

    // Validate restaurant ID
    if (product.restaurantId.isEmpty || product.restaurantId.trim().isEmpty) {
      String message = 'Invalid product. Please try again.';
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        message = l10n?.invalidProduct ?? message;
      }
      ToastService.showError(message);
      return;
    }

    if (quantity <= 0) {
      String message = 'Quantity must be greater than zero';
      if (context != null) {
        final l10n = AppLocalizations.of(context);
        message = l10n?.quantityMustBeGreaterThanZero ?? message;
      }
      ToastService.showError(message);
      return;
    }

    // Check if adding item from different restaurant
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      if (currentState.restaurantId != null &&
          currentState.restaurantId != product.restaurantId) {
        String message =
            'Cannot add products from different restaurants. Please clear cart first.';
        if (context != null) {
          final l10n = AppLocalizations.of(context);
          message = l10n?.cannotAddDifferentRestaurant ?? message;
        }
        ToastService.showWarning(message);
        return;
      }
    }

    final item = CartItemEntity(product: product, quantity: quantity);

    final result = await repository.addItem(userId, item);

    result.fold(
      (failure) {
        // Show user-friendly error message
        final errorMessage = _getUserFriendlyErrorMessage(
          failure.message,
          context,
        );
        ToastService.showError(errorMessage);
      },
      (_) {
        // Success - show success message if context is available
        if (context != null) {
          final l10n = AppLocalizations.of(context);
          final message =
              l10n?.itemAddedToCart(product.name) ??
              '${product.name} added to cart';
          ToastService.showSuccess(message);
        }
        // State will be updated via stream
      },
    );
  }

  String _getUserFriendlyErrorMessage(String error, [BuildContext? context]) {
    // Try to get localized messages if context is available
    final l10n = context != null ? AppLocalizations.of(context) : null;

    // Map technical errors to user-friendly messages
    if (error.contains('Product ID is required') ||
        error.contains('Product ID is missing')) {
      return l10n?.invalidProduct ?? 'Invalid product. Please try again.';
    }
    if (error.contains('User ID is required') ||
        error.contains('not authenticated')) {
      return l10n?.pleaseLoginToContinue ?? 'Please login to continue';
    }
    if (error.contains('Failed to add item to cart')) {
      return l10n?.failedToAddItemToCart ??
          'Failed to add item to cart. Please try again.';
    }
    if (error.contains('document path must be a non-empty string')) {
      return l10n?.invalidProduct ?? 'Invalid product. Please try again.';
    }

    // Return user-friendly version of error
    return error.replaceAll('Failed to add item to cart: ', '');
  }

  Future<void> removeItem(String productId) async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    final result = await repository.removeItem(userId, productId);

    result.fold((failure) => emit(CartError(failure.message)), (_) {
      // State will be updated via stream
    });
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final result = await repository.updateItemQuantity(
      userId,
      productId,
      quantity,
    );

    result.fold((failure) => emit(CartError(failure.message)), (_) {
      // State will be updated via stream
    });
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    final result = await repository.clearCart(userId);

    result.fold((failure) => emit(CartError(failure.message)), (_) {
      emit(CartLoaded([]));
    });
  }

  int getItemCount() {
    if (state is CartLoaded) {
      return (state as CartLoaded).itemCount;
    }
    return 0;
  }

  double getTotalPrice() {
    if (state is CartLoaded) {
      return (state as CartLoaded).totalPrice;
    }
    return 0.0;
  }

  /// Remove items from other restaurants (helper method)
  Future<void> _removeItemsFromOtherRestaurants(
    String userId,
    String targetRestaurantId,
    List<CartItemEntity> allItems,
  ) async {
    // Remove items that don't belong to target restaurant
    for (final item in allItems) {
      if (item.product.restaurantId != targetRestaurantId) {
        await repository.removeItem(userId, item.product.id);
      }
    }
  }

  /// Validate cart before checkout
  Future<bool> validateCartForCheckout() async {
    final userId = _userId;
    if (userId == null) return false;

    if (state is! CartLoaded) return false;

    final cartState = state as CartLoaded;

    // Check if cart is empty
    if (cartState.items.isEmpty) return false;

    // Validate all items have same restaurant
    if (cartState.restaurantId == null) return false;

    final allSameRestaurant = cartState.items.every(
      (item) => item.product.restaurantId == cartState.restaurantId,
    );

    if (!allSameRestaurant) return false;

    // Validate all items have valid quantities
    final allValidQuantities = cartState.items.every(
      (item) => item.quantity > 0 && item.product.price > 0,
    );

    if (!allValidQuantities) return false;

    return true;
  }
}
