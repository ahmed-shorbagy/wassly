part of 'delivery_address_cubit.dart';

abstract class DeliveryAddressState extends Equatable {
  const DeliveryAddressState();

  @override
  List<Object?> get props => [];
}

class DeliveryAddressInitial extends DeliveryAddressState {}

class DeliveryAddressLoading extends DeliveryAddressState {}

class DeliveryAddressNotSet extends DeliveryAddressState {}

class DeliveryAddressSelected extends DeliveryAddressState {
  final String address;
  final String? addressLabel;

  const DeliveryAddressSelected({
    required this.address,
    this.addressLabel,
  });

  String get displayAddress {
    if (addressLabel != null && addressLabel!.isNotEmpty) {
      return '$addressLabel: $address';
    }
    return address;
  }

  @override
  List<Object?> get props => [address, addressLabel];
}

class DeliveryAddressError extends DeliveryAddressState {
  final String message;

  const DeliveryAddressError(this.message);

  @override
  List<Object?> get props => [message];
}

