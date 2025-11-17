part of 'market_product_customer_cubit.dart';

abstract class MarketProductCustomerState extends Equatable {
  const MarketProductCustomerState();

  @override
  List<Object?> get props => [];
}

class MarketProductCustomerInitial extends MarketProductCustomerState {}

class MarketProductCustomerLoading extends MarketProductCustomerState {}

class MarketProductCustomerLoaded extends MarketProductCustomerState {
  final List<MarketProductEntity> products;

  const MarketProductCustomerLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class MarketProductCustomerError extends MarketProductCustomerState {
  final String message;

  const MarketProductCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

