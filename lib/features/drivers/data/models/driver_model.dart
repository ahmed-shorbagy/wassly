import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    super.personalImageUrl,
    super.driverLicenseUrl,
    super.vehicleLicenseUrl,
    super.vehiclePhotoUrl,
    super.vehicleType,
    super.vehicleModel,
    super.vehicleColor,
    super.vehiclePlateNumber,
    super.address,
    super.isActive,
    super.isOnline,
    super.rating,
    super.totalDeliveries,
    required super.createdAt,
    super.updatedAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      personalImageUrl: json['personalImageUrl'],
      driverLicenseUrl: json['driverLicenseUrl'],
      vehicleLicenseUrl: json['vehicleLicenseUrl'],
      vehiclePhotoUrl: json['vehiclePhotoUrl'],
      vehicleType: json['vehicleType'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      vehiclePlateNumber: json['vehiclePlateNumber'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      isOnline: json['isOnline'] ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalDeliveries: json['totalDeliveries'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory DriverModel.fromEntity(DriverEntity entity) {
    return DriverModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      personalImageUrl: entity.personalImageUrl,
      driverLicenseUrl: entity.driverLicenseUrl,
      vehicleLicenseUrl: entity.vehicleLicenseUrl,
      vehiclePhotoUrl: entity.vehiclePhotoUrl,
      vehicleType: entity.vehicleType,
      vehicleModel: entity.vehicleModel,
      vehicleColor: entity.vehicleColor,
      vehiclePlateNumber: entity.vehiclePlateNumber,
      address: entity.address,
      isActive: entity.isActive,
      isOnline: entity.isOnline,
      rating: entity.rating,
      totalDeliveries: entity.totalDeliveries,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'personalImageUrl': personalImageUrl,
      'driverLicenseUrl': driverLicenseUrl,
      'vehicleLicenseUrl': vehicleLicenseUrl,
      'vehiclePhotoUrl': vehiclePhotoUrl,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehiclePlateNumber': vehiclePlateNumber,
      'address': address,
      'isActive': isActive,
      'isOnline': isOnline,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory DriverModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel.fromJson({...data, 'id': doc.id});
  }
}

