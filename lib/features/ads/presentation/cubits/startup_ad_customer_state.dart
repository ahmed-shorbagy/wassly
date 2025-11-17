part of 'startup_ad_customer_cubit.dart';

abstract class StartupAdCustomerState extends Equatable {
  const StartupAdCustomerState();

  @override
  List<Object?> get props => [];
}

class StartupAdCustomerInitial extends StartupAdCustomerState {}

class StartupAdCustomerLoading extends StartupAdCustomerState {}

class StartupAdCustomerLoaded extends StartupAdCustomerState {
  final List<StartupAdEntity> ads;

  const StartupAdCustomerLoaded(this.ads);

  @override
  List<Object?> get props => [ads];
}

class StartupAdCustomerError extends StartupAdCustomerState {
  final String message;

  const StartupAdCustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

