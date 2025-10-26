import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? imageUrl;
  final String address;
  final Map<String, dynamic> location;
  final bool isOpen;
  final DateTime createdAt;

  const RestaurantEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.address,
    required this.location,
    required this.isOpen,
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
    location,
    isOpen,
    createdAt,
  ];
}
