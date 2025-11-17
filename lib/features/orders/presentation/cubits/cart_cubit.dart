import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  final FirebaseAuth firebaseAuth;

  CartCubit({
    required this.repository,
    required this.firebaseAuth,
  }) : super(CartInitial()) {
    _loadCart();
  }

  String? get _userId => firebaseAuth.currentUser?.uid;

  void _loadCart() {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    emit(CartLoading());

    repository.getCartStream(userId).listen(
      (items) {
        // Determine restaurant ID from items
        String? restaurantId;
        if (items.isNotEmpty) {
          restaurantId = items.first.product.restaurantId;
        }

        emit(CartLoaded(items, restaurantId: restaurantId));
      },
      onError: (error) {
        emit(CartError(error.toString()));
      },
    );
  }

  Future<void> addItem(ProductEntity product, {int quantity = 1}) async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    // Check if adding item from different restaurant
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      if (currentState.restaurantId != null &&
          currentState.restaurantId != product.restaurantId) {
        emit(CartError(
          'لا يمكن إضافة منتجات من مطاعم مختلفة. يرجى إفراغ السلة أولاً.',
        ));
        return;
      }
    }

    final item = CartItemEntity(product: product, quantity: quantity);

    final result = await repository.addItem(userId, item);

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {
        // State will be updated via stream
      },
    );
  }

  Future<void> removeItem(String productId) async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    final result = await repository.removeItem(userId, productId);

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {
        // State will be updated via stream
      },
    );
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

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {
        // State will be updated via stream
      },
    );
  }

  Future<void> clearCart() async {
    final userId = _userId;
    if (userId == null) {
      emit(const CartError('User not authenticated'));
      return;
    }

    final result = await repository.clearCart(userId);

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {
        emit(CartLoaded([]));
      },
    );
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
}
