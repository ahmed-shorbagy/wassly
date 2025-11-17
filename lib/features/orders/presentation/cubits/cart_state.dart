part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final String? restaurantId; // Track which restaurant the cart belongs to

  const CartLoaded(this.items, {this.restaurantId});

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    String? restaurantId,
  }) {
    return CartLoaded(
      items ?? this.items,
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }

  @override
  List<Object?> get props => [items, restaurantId];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}
