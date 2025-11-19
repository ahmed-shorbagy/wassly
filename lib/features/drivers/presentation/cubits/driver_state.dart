part of 'driver_cubit.dart';

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object> get props => [];
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriversLoaded extends DriverState {
  final List<DriverEntity> drivers;

  const DriversLoaded(this.drivers);

  @override
  List<Object> get props => [drivers];
}

class DriverLoaded extends DriverState {
  final DriverEntity driver;

  const DriverLoaded(this.driver);

  @override
  List<Object> get props => [driver];
}

class DriverCreated extends DriverState {
  final DriverEntity driver;

  const DriverCreated(this.driver);

  @override
  List<Object> get props => [driver];
}

class DriverUpdated extends DriverState {
  final DriverEntity driver;

  const DriverUpdated(this.driver);

  @override
  List<Object> get props => [driver];
}

class DriverDeleted extends DriverState {}

class DriverError extends DriverState {
  final String message;

  const DriverError(this.message);

  @override
  List<Object> get props => [message];
}

