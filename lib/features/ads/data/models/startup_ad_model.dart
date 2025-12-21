import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/startup_ad_entity.dart';

class StartupAdModel extends StartupAdEntity {
  const StartupAdModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.description,
    super.deepLink,
    super.restaurantId,
    super.restaurantName,
    required super.isActive,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StartupAdModel.fromJson(Map<String, dynamic> json) {
    return StartupAdModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'],
      description: json['description'],
      deepLink: json['deepLink'],
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      isActive: json['isActive'] ?? true,
      priority: json['priority'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory StartupAdModel.fromEntity(StartupAdEntity entity) {
    return StartupAdModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      title: entity.title,
      description: entity.description,
      deepLink: entity.deepLink,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      isActive: entity.isActive,
      priority: entity.priority,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'deepLink': deepLink,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'isActive': isActive,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'deepLink': deepLink,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'isActive': isActive,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory StartupAdModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StartupAdModel.fromJson({...data, 'id': doc.id});
  }

  StartupAdModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? description,
    String? deepLink,
    String? restaurantId,
    String? restaurantName,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StartupAdModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      deepLink: deepLink ?? this.deepLink,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

