import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    super.imageUrl,
    required super.address,
    required super.location,
    required super.isOpen,
    required super.createdAt,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // Handle location - can be GeoPoint or Map
    Map<String, dynamic> locationData = {};
    if (json['location'] != null) {
      if (json['location'] is GeoPoint) {
        final geoPoint = json['location'] as GeoPoint;
        locationData = {
          'latitude': geoPoint.latitude,
          'longitude': geoPoint.longitude,
        };
      } else if (json['location'] is Map) {
        locationData = Map<String, dynamic>.from(json['location'] as Map);
      }
    }

    return RestaurantModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      address: json['address'] ?? '',
      location: locationData,
      isOpen: json['isOpen'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory RestaurantModel.fromEntity(RestaurantEntity entity) {
    return RestaurantModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      address: entity.address,
      location: entity.location,
      isOpen: entity.isOpen,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'address': address,
      'location': location,
      'isOpen': isOpen,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    Map<String, dynamic>? location,
    bool? isOpen,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
