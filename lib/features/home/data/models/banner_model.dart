import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.deepLink,
    super.type = 'home',
    this.isActive,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  final bool? isActive;
  final int? priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'],
      deepLink: json['deepLink'],
      type: json['type'] ?? 'home',
      isActive: json['isActive'],
      priority: json['priority'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      title: entity.title,
      deepLink: entity.deepLink,
      type: entity.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'deepLink': deepLink,
      'type': type,
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'deepLink': deepLink,
      'type': type,
      'isActive': isActive ?? true,
      'priority': priority ?? 0,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel.fromJson({...data, 'id': doc.id});
  }

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? deepLink,
    String? type,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      deepLink: deepLink ?? this.deepLink,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
