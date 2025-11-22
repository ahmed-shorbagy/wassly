import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryAddressEntity extends Equatable {
  final String id;
  final String userId;
  final String address;
  final String? addressLabel; // e.g., "Home", "Work", "Office"
  final GeoPoint location;
  final String? buildingNumber;
  final String? apartmentNumber;
  final String? floorNumber;
  final String? additionalNotes;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryAddressEntity({
    required this.id,
    required this.userId,
    required this.address,
    this.addressLabel,
    required this.location,
    this.buildingNumber,
    this.apartmentNumber,
    this.floorNumber,
    this.additionalNotes,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress {
    final parts = <String>[];
    if (addressLabel != null && addressLabel!.isNotEmpty) {
      parts.add(addressLabel!);
    }
    parts.add(address);
    if (buildingNumber != null && buildingNumber!.isNotEmpty) {
      parts.add('مبنى $buildingNumber');
    }
    if (floorNumber != null && floorNumber!.isNotEmpty) {
      parts.add('طابق $floorNumber');
    }
    if (apartmentNumber != null && apartmentNumber!.isNotEmpty) {
      parts.add('شقة $apartmentNumber');
    }
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        address,
        addressLabel,
        location,
        buildingNumber,
        apartmentNumber,
        floorNumber,
        additionalNotes,
        isDefault,
        createdAt,
        updatedAt,
      ];
}

