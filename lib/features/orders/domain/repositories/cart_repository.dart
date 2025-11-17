import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  /// Get cart items stream for a user
  Stream<List<CartItemEntity>> getCartStream(String userId);

  /// Add item to cart
  Future<Either<Failure, void>> addItem(
    String userId,
    CartItemEntity item,
  );

  /// Update item quantity in cart
  Future<Either<Failure, void>> updateItemQuantity(
    String userId,
    String productId,
    int quantity,
  );

  /// Remove item from cart
  Future<Either<Failure, void>> removeItem(
    String userId,
    String productId,
  );

  /// Clear entire cart
  Future<Either<Failure, void>> clearCart(String userId);
}

