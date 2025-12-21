import 'package:equatable/equatable.dart';

class StartupAdEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String? description;
  final String? deepLink;
  final String? restaurantId;
  final String? restaurantName;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StartupAdEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    this.deepLink,
    this.restaurantId,
    this.restaurantName,
    required this.isActive,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        title,
        description,
        deepLink,
        restaurantId,
        restaurantName,
        isActive,
        priority,
        createdAt,
        updatedAt,
      ];
}

