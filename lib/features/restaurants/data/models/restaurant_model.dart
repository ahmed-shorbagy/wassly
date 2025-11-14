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
    required super.phone,
    super.email,
    super.categories,
    required super.location,
    required super.isOpen,
    super.rating,
    super.totalReviews,
    super.deliveryFee,
    super.minOrderAmount,
    super.estimatedDeliveryTime,
    super.commercialRegistrationPhotoUrl,
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

    // Handle categories
    List<String> categoriesList = [];
    if (json['categories'] != null) {
      if (json['categories'] is List) {
        categoriesList = List<String>.from(json['categories']);
      }
    }

    return RestaurantModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      categories: categoriesList,
      location: locationData,
      isOpen: json['isOpen'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? 30,
      commercialRegistrationPhotoUrl: json['commercialRegistrationPhotoUrl'],
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
      phone: entity.phone,
      email: entity.email,
      categories: entity.categories,
      location: entity.location,
      isOpen: entity.isOpen,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      deliveryFee: entity.deliveryFee,
      minOrderAmount: entity.minOrderAmount,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      commercialRegistrationPhotoUrl: entity.commercialRegistrationPhotoUrl,
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
      'phone': phone,
      'email': email,
      'categories': categories,
      'location': location,
      'isOpen': isOpen,
      'rating': rating,
      'totalReviews': totalReviews,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'commercialRegistrationPhotoUrl': commercialRegistrationPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel.fromJson({...data, 'id': doc.id});
  }

  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phone,
    String? email,
    List<String>? categories,
    Map<String, dynamic>? location,
    bool? isOpen,
    double? rating,
    int? totalReviews,
    double? deliveryFee,
    double? minOrderAmount,
    int? estimatedDeliveryTime,
    String? commercialRegistrationPhotoUrl,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      commercialRegistrationPhotoUrl: commercialRegistrationPhotoUrl ?? this.commercialRegistrationPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
