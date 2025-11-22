import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_address_entity.dart';

class DeliveryAddressModel extends DeliveryAddressEntity {
  const DeliveryAddressModel({
    required super.id,
    required super.userId,
    required super.address,
    super.addressLabel,
    required super.location,
    super.buildingNumber,
    super.apartmentNumber,
    super.floorNumber,
    super.additionalNotes,
    required super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeliveryAddressModel.fromEntity(DeliveryAddressEntity entity) {
    return DeliveryAddressModel(
      id: entity.id,
      userId: entity.userId,
      address: entity.address,
      addressLabel: entity.addressLabel,
      location: entity.location,
      buildingNumber: entity.buildingNumber,
      apartmentNumber: entity.apartmentNumber,
      floorNumber: entity.floorNumber,
      additionalNotes: entity.additionalNotes,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory DeliveryAddressModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DeliveryAddressModel(
      id: doc.id,
      userId: data['userId'] as String,
      address: data['address'] as String,
      addressLabel: data['addressLabel'] as String?,
      location: data['location'] as GeoPoint,
      buildingNumber: data['buildingNumber'] as String?,
      apartmentNumber: data['apartmentNumber'] as String?,
      floorNumber: data['floorNumber'] as String?,
      additionalNotes: data['additionalNotes'] as String?,
      isDefault: data['isDefault'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'address': address,
      'addressLabel': addressLabel,
      'location': location,
      'buildingNumber': buildingNumber,
      'apartmentNumber': apartmentNumber,
      'floorNumber': floorNumber,
      'additionalNotes': additionalNotes,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DeliveryAddressModel copyWith({
    String? id,
    String? userId,
    String? address,
    String? addressLabel,
    GeoPoint? location,
    String? buildingNumber,
    String? apartmentNumber,
    String? floorNumber,
    String? additionalNotes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryAddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      addressLabel: addressLabel ?? this.addressLabel,
      location: location ?? this.location,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      floorNumber: floorNumber ?? this.floorNumber,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

