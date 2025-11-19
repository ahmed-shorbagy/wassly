import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String userId; // Reference to UserEntity
  final String name;
  final String email;
  final String phone;
  final String? personalImageUrl;
  final String? driverLicenseUrl;
  final String? vehicleLicenseUrl;
  final String? vehiclePhotoUrl;
  final String? vehicleType; // e.g., "motorcycle", "car", "truck"
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePlateNumber;
  final String? address;
  final bool isActive;
  final bool isOnline;
  final double? rating;
  final int? totalDeliveries;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DriverEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.personalImageUrl,
    this.driverLicenseUrl,
    this.vehicleLicenseUrl,
    this.vehiclePhotoUrl,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePlateNumber,
    this.address,
    this.isActive = true,
    this.isOnline = false,
    this.rating,
    this.totalDeliveries,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        personalImageUrl,
        driverLicenseUrl,
        vehicleLicenseUrl,
        vehiclePhotoUrl,
        vehicleType,
        vehicleModel,
        vehicleColor,
        vehiclePlateNumber,
        address,
        isActive,
        isOnline,
        rating,
        totalDeliveries,
        createdAt,
        updatedAt,
      ];

  DriverEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? personalImageUrl,
    String? driverLicenseUrl,
    String? vehicleLicenseUrl,
    String? vehiclePhotoUrl,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlateNumber,
    String? address,
    bool? isActive,
    bool? isOnline,
    double? rating,
    int? totalDeliveries,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      personalImageUrl: personalImageUrl ?? this.personalImageUrl,
      driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
      vehicleLicenseUrl: vehicleLicenseUrl ?? this.vehicleLicenseUrl,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

