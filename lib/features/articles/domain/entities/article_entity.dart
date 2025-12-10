import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? author;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.author,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imageUrl,
        author,
        isPublished,
        createdAt,
        updatedAt,
      ];
}

