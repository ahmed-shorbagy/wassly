part of 'market_product_cubit.dart';

abstract class MarketProductState extends Equatable {
  const MarketProductState();

  @override
  List<Object?> get props => [];
}

class MarketProductInitial extends MarketProductState {}

class MarketProductLoading extends MarketProductState {}

class MarketProductLoaded extends MarketProductState {
  final List<MarketProductEntity> products;

  const MarketProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class MarketProductAdded extends MarketProductState {
  final MarketProductEntity product;

  const MarketProductAdded(this.product);

  @override
  List<Object?> get props => [product];
}

class MarketProductUpdated extends MarketProductState {}

class MarketProductDeleted extends MarketProductState {}

class MarketProductAvailabilityToggled extends MarketProductState {}

class MarketProductError extends MarketProductState {
  final String message;

  const MarketProductError(this.message);

  @override
  List<Object?> get props => [message];
}

