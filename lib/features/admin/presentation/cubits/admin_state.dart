part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class RestaurantCreatedSuccess extends AdminState {
  final String restaurantId;

  const RestaurantCreatedSuccess(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

class RestaurantStatusUpdated extends AdminState {}

class RestaurantDeletedSuccess extends AdminState {}

class RestaurantUpdatedSuccess extends AdminState {}

class RestaurantLoaded extends AdminState {
  final RestaurantEntity restaurant;

  const RestaurantLoaded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class AdminProductsLoaded extends AdminState {
  final List<ProductEntity> products;

  const AdminProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class PendingPartnersLoaded extends AdminState {
  final List<dynamic>
  pendingPartners; // Can be RestaurantEntity or DriverEntity

  const PendingPartnersLoaded(this.pendingPartners);

  @override
  List<Object?> get props => [pendingPartners];
}

class PartnerApprovedSuccess extends AdminState {}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
