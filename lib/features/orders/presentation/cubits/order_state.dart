part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreating extends OrderState {}

class OrderCancelling extends OrderState {}

class OrderLoaded extends OrderState {
  final OrderEntity order;

  const OrderLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

