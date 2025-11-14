part of 'admin_product_cubit.dart';

abstract class AdminProductState extends Equatable {
  const AdminProductState();

  @override
  List<Object?> get props => [];
}

class AdminProductInitial extends AdminProductState {}

class AdminProductLoading extends AdminProductState {}

class AdminProductLoaded extends AdminProductState {
  final List<ProductEntity> products;

  const AdminProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class AdminProductAdded extends AdminProductState {}

class AdminProductUpdated extends AdminProductState {}

class AdminProductDeleted extends AdminProductState {}

class AdminProductError extends AdminProductState {
  final String message;

  const AdminProductError(this.message);

  @override
  List<Object?> get props => [message];
}

