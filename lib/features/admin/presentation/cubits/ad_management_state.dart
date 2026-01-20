part of 'ad_management_cubit.dart';

abstract class AdManagementState extends Equatable {
  const AdManagementState();

  @override
  List<Object?> get props => [];
}

class AdManagementInitial extends AdManagementState {}

class AdManagementLoading extends AdManagementState {}

class StartupAdsLoaded extends AdManagementState {
  final List<StartupAdEntity> ads;

  const StartupAdsLoaded(this.ads);

  @override
  List<Object?> get props => [ads];
}

class StartupAdAdded extends AdManagementState {
  final StartupAdEntity ad;

  const StartupAdAdded(this.ad);

  @override
  List<Object?> get props => [ad];
}

class StartupAdUpdated extends AdManagementState {}

class StartupAdDeleted extends AdManagementState {}

class StartupAdStatusToggled extends AdManagementState {}

class BannerAdsLoaded extends AdManagementState {
  final List<BannerEntity> banners;

  const BannerAdsLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class BannerAdAdded extends AdManagementState {
  final BannerEntity banner;

  const BannerAdAdded(this.banner);

  @override
  List<Object?> get props => [banner];
}

class BannerAdUpdated extends AdManagementState {}

class BannerAdDeleted extends AdManagementState {}

class BannerAdStatusToggled extends AdManagementState {}

// Promotional Images
class PromotionalImagesLoaded extends AdManagementState {
  final List<PromotionalImageEntity> images;

  const PromotionalImagesLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class PromotionalImageAdded extends AdManagementState {
  final PromotionalImageEntity image;

  const PromotionalImageAdded(this.image);

  @override
  List<Object?> get props => [image];
}

class PromotionalImageUpdated extends AdManagementState {}

class PromotionalImageDeleted extends AdManagementState {}

class PromotionalImageStatusToggled extends AdManagementState {}

class AdManagementError extends AdManagementState {
  final String message;

  const AdManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
