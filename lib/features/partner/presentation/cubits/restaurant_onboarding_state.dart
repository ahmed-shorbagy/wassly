part of 'restaurant_onboarding_cubit.dart';

abstract class RestaurantOnboardingState extends Equatable {
  const RestaurantOnboardingState();

  @override
  List<Object?> get props => [];
}

class RestaurantOnboardingInitial extends RestaurantOnboardingState {}

class RestaurantOnboardingLoading extends RestaurantOnboardingState {}

class RestaurantOnboardingSuccess extends RestaurantOnboardingState {
  final RestaurantEntity restaurant;

  const RestaurantOnboardingSuccess(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantOnboardingError extends RestaurantOnboardingState {
  final String message;

  const RestaurantOnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

