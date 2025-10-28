import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../restaurants/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  void addItem(ProductEntity product, {int quantity = 1}) {
    final currentItems = List<CartItemEntity>.from(
      state is CartLoaded ? (state as CartLoaded).items : [],
    );

    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity if item already exists
      final existingItem = currentItems[existingIndex];
      currentItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      currentItems.add(CartItemEntity(product: product, quantity: quantity));
    }

    emit(CartLoaded(currentItems));
  }

  void removeItem(String productId) {
    final currentItems = List<CartItemEntity>.from(
      state is CartLoaded ? (state as CartLoaded).items : [],
    );

    currentItems.removeWhere((item) => item.product.id == productId);
    emit(CartLoaded(currentItems));
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final currentItems = List<CartItemEntity>.from(
      state is CartLoaded ? (state as CartLoaded).items : [],
    );

    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(quantity: quantity);
      emit(CartLoaded(currentItems));
    }
  }

  void clearCart() {
    emit(CartInitial());
  }

  int getItemCount() {
    if (state is CartLoaded) {
      return (state as CartLoaded).items.length;
    }
    return 0;
  }

  double getTotalPrice() {
    if (state is CartLoaded) {
      return (state as CartLoaded).items.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
    }
    return 0.0;
  }
}
