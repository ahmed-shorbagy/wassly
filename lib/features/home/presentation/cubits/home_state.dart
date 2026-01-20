part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BannerEntity> banners;
  final List<RestaurantCategoryEntity> categories;
  final List<PromotionalImageEntity> promotionalImages;

  const HomeLoaded({
    this.banners = const [],
    this.categories = const [],
    this.promotionalImages = const [],
  });

  @override
  List<Object?> get props => [banners, categories, promotionalImages];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
