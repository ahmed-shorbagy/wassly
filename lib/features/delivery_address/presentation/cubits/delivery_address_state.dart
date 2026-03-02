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
  final String? addressId;

  const DeliveryAddressSelected({
    required this.address,
    this.addressLabel,
    this.addressId,
  });

  String get displayAddress {
    if (addressLabel != null && addressLabel!.isNotEmpty) {
      return '$addressLabel: $address';
    }
    return address;
  }

  @override
  List<Object?> get props => [address, addressLabel, addressId];
}

class DeliveryAddressesLoaded extends DeliveryAddressState {
  final List<DeliveryAddressEntity> addresses;
  final DeliveryAddressEntity? selectedAddress;

  const DeliveryAddressesLoaded({
    required this.addresses,
    this.selectedAddress,
  });

  @override
  List<Object?> get props => [addresses, selectedAddress];
}

class DeliveryAddressError extends DeliveryAddressState {
  final String message;

  const DeliveryAddressError(this.message);

  @override
  List<Object?> get props => [message];
}

extension DeliveryAddressStateX on DeliveryAddressState {
  String? get selectedAddressDisplay {
    if (this is DeliveryAddressSelected) {
      return (this as DeliveryAddressSelected).displayAddress;
    } else if (this is DeliveryAddressesLoaded) {
      final selected = (this as DeliveryAddressesLoaded).selectedAddress;
      if (selected != null) {
        if (selected.addressLabel != null &&
            selected.addressLabel!.isNotEmpty) {
          return '${selected.addressLabel}: ${selected.fullAddress}';
        }
        return selected.fullAddress;
      }
    }
    return null;
  }

  String? get currentAddressId {
    if (this is DeliveryAddressSelected) {
      return (this as DeliveryAddressSelected).addressId;
    } else if (this is DeliveryAddressesLoaded) {
      return (this as DeliveryAddressesLoaded).selectedAddress?.id;
    }
    return null;
  }
}
