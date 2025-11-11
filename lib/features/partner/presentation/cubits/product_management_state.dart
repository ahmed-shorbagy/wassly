part of 'product_management_cubit.dart';

abstract class ProductManagementState extends Equatable {
  const ProductManagementState();

  @override
  List<Object?> get props => [];
}

class ProductManagementInitial extends ProductManagementState {}

class ProductManagementLoading extends ProductManagementState {}

class ProductAvailabilityToggled extends ProductManagementState {}

class ProductDeleted extends ProductManagementState {}

class ProductManagementError extends ProductManagementState {
  final String message;

  const ProductManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

