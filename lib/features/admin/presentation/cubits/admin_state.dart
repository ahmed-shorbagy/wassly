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

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

