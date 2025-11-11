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
  final List<String> categories;
  final Map<String, dynamic> location;
  final bool isOpen;
  final double rating;
  final int totalReviews;
  final double deliveryFee;
  final double minOrderAmount;
  final int estimatedDeliveryTime;
  final DateTime createdAt;

  const RestaurantEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.address,
    required this.phone,
    this.email,
    this.categories = const [],
    required this.location,
    required this.isOpen,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.deliveryFee = 0.0,
    this.minOrderAmount = 0.0,
    this.estimatedDeliveryTime = 30,
    required this.createdAt,
  });

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
        categories,
        location,
        isOpen,
        rating,
        totalReviews,
        deliveryFee,
        minOrderAmount,
        estimatedDeliveryTime,
        createdAt,
      ];
}
