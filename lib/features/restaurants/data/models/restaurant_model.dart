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
    super.categoryIds,
    required super.location,
    required super.isOpen,
    super.rating,
    super.totalReviews,
    super.deliveryFee,
    super.minOrderAmount,
    super.estimatedDeliveryTime,
    super.commercialRegistrationPhotoUrl,
    super.hasDiscount,
    super.discountPercentage,
    super.discountDescription,
    super.discountStartDate,
    super.discountEndDate,
    super.discountImageUrl,
    super.discountTargetProductId,
    required super.createdAt,
    super.isApproved,
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
    if (json['categoryIds'] != null) {
      if (json['categoryIds'] is List) {
        categoriesList = List<String>.from(json['categoryIds']);
      }
    } else if (json['categories'] != null) {
      // Backward compatibility
      if (json['categories'] is List) {
        categoriesList = List<String>.from(json['categories']);
      }
    }

    // Handle discount dates
    DateTime? discountStartDate;
    DateTime? discountEndDate;
    if (json['discountStartDate'] != null) {
      discountStartDate = (json['discountStartDate'] as Timestamp).toDate();
    }
    if (json['discountEndDate'] != null) {
      discountEndDate = (json['discountEndDate'] as Timestamp).toDate();
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
      categoryIds: categoriesList,
      location: locationData,
      isOpen: json['isOpen'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? 30,
      commercialRegistrationPhotoUrl: json['commercialRegistrationPhotoUrl'],
      hasDiscount: json['hasDiscount'] ?? false,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] as num).toDouble()
          : null,
      discountDescription: json['discountDescription'],
      discountStartDate: discountStartDate,
      discountEndDate: discountEndDate,
      discountImageUrl: json['discountImageUrl'],
      discountTargetProductId: json['discountTargetProductId'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isApproved: json['isApproved'] ?? false,
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
      categoryIds: entity.categoryIds,
      location: entity.location,
      isOpen: entity.isOpen,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      deliveryFee: entity.deliveryFee,
      minOrderAmount: entity.minOrderAmount,
      estimatedDeliveryTime: entity.estimatedDeliveryTime,
      commercialRegistrationPhotoUrl: entity.commercialRegistrationPhotoUrl,
      hasDiscount: entity.hasDiscount,
      discountPercentage: entity.discountPercentage,
      discountDescription: entity.discountDescription,
      discountStartDate: entity.discountStartDate,
      discountEndDate: entity.discountEndDate,
      discountImageUrl: entity.discountImageUrl,
      discountTargetProductId: entity.discountTargetProductId,
      createdAt: entity.createdAt,
      isApproved: entity.isApproved,
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
      'categoryIds': categoryIds,
      'location': location,
      'isOpen': isOpen,
      'rating': rating,
      'totalReviews': totalReviews,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'commercialRegistrationPhotoUrl': commercialRegistrationPhotoUrl,
      'hasDiscount': hasDiscount,
      'discountPercentage': discountPercentage,
      'discountDescription': discountDescription,
      'discountStartDate': discountStartDate != null
          ? Timestamp.fromDate(discountStartDate!)
          : null,
      'discountEndDate': discountEndDate != null
          ? Timestamp.fromDate(discountEndDate!)
          : null,
      'discountImageUrl': discountImageUrl,
      'discountTargetProductId': discountTargetProductId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isApproved': isApproved,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel.fromJson({...data, 'id': doc.id});
  }

  @override
  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    String? address,
    String? phone,
    String? email,
    List<String>? categoryIds,
    Map<String, dynamic>? location,
    bool? isOpen,
    double? rating,
    int? totalReviews,
    double? deliveryFee,
    double? minOrderAmount,
    int? estimatedDeliveryTime,
    String? commercialRegistrationPhotoUrl,
    bool? hasDiscount,
    double? discountPercentage,
    String? discountDescription,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    String? discountImageUrl,
    String? discountTargetProductId,
    DateTime? createdAt,
    bool? isApproved,
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
      categoryIds: categoryIds ?? this.categoryIds,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      commercialRegistrationPhotoUrl:
          commercialRegistrationPhotoUrl ?? this.commercialRegistrationPhotoUrl,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountDescription: discountDescription ?? this.discountDescription,
      discountStartDate: discountStartDate ?? this.discountStartDate,
      discountEndDate: discountEndDate ?? this.discountEndDate,
      discountImageUrl: discountImageUrl ?? this.discountImageUrl,
      discountTargetProductId:
          discountTargetProductId ?? this.discountTargetProductId,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
