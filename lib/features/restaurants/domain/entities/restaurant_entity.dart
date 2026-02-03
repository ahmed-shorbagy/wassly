import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? imageUrl;
  final String address;
  final String phone;
  final String? email;
  final List<String> categoryIds;
  final Map<String, dynamic> location;
  final bool isOpen;
  final double rating;
  final int totalReviews;
  final double deliveryFee;
  final double minOrderAmount;
  final int estimatedDeliveryTime;
  final String? commercialRegistrationPhotoUrl;
  final bool hasDiscount;
  final double? discountPercentage;
  final String? discountDescription;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final String? discountImageUrl;
  final String? discountTargetProductId;
  final DateTime createdAt;
  final bool isApproved;

  const RestaurantEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.address,
    required this.phone,
    this.email,
    this.categoryIds = const [],
    required this.location,
    required this.isOpen,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.deliveryFee = 0.0,
    this.minOrderAmount = 0.0,
    this.estimatedDeliveryTime = 30,
    this.commercialRegistrationPhotoUrl,
    this.hasDiscount = false,
    this.discountPercentage,
    this.discountDescription,
    this.discountStartDate,
    this.discountEndDate,
    this.discountImageUrl,
    this.discountTargetProductId,
    required this.createdAt,
    this.isApproved = false,
  });

  /// Check if discount is currently active
  bool get isDiscountActive {
    if (!hasDiscount || discountPercentage == null) return false;
    final now = DateTime.now();
    if (discountStartDate != null && now.isBefore(discountStartDate!)) {
      return false;
    }
    if (discountEndDate != null && now.isAfter(discountEndDate!)) {
      return false;
    }
    return true;
  }

  RestaurantEntity copyWith({
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
    return RestaurantEntity(
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

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    imageUrl,
    address,
    phone,
    email,
    categoryIds,
    location,
    isOpen,
    rating,
    totalReviews,
    deliveryFee,
    minOrderAmount,
    estimatedDeliveryTime,
    commercialRegistrationPhotoUrl,
    hasDiscount,
    discountPercentage,
    discountDescription,
    discountStartDate,
    discountEndDate,
    discountImageUrl,
    discountTargetProductId,
    createdAt,
    isApproved,
  ];
}
