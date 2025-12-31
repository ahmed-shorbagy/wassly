import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String? deepLink;
  final String type; // 'home' or 'market'

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.deepLink,
    this.type = 'home',
  });

  @override
  List<Object?> get props => [id, imageUrl, title, deepLink, type];
}
