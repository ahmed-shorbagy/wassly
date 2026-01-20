import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/startup_ad_entity.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../home/domain/entities/promotional_image_entity.dart';

abstract class AdRepository {
  /// Upload an image file
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  );

  // Startup Ads
  Future<Either<Failure, List<StartupAdEntity>>> getAllStartupAds();
  Future<Either<Failure, StartupAdEntity>> getStartupAdById(String adId);
  Future<Either<Failure, StartupAdEntity>> createStartupAd(StartupAdEntity ad);
  Future<Either<Failure, void>> updateStartupAd(StartupAdEntity ad);
  Future<Either<Failure, void>> deleteStartupAd(String adId);
  Future<Either<Failure, void>> toggleStartupAdStatus(
    String adId,
    bool isActive,
  );

  // Banner Ads
  Future<Either<Failure, List<BannerEntity>>> getAllBannerAds();
  Future<Either<Failure, BannerEntity>> getBannerAdById(String bannerId);
  Future<Either<Failure, BannerEntity>> createBannerAd(BannerEntity banner);
  Future<Either<Failure, void>> updateBannerAd(BannerEntity banner);
  Future<Either<Failure, void>> deleteBannerAd(String bannerId);
  Future<Either<Failure, void>> toggleBannerAdStatus(
    String bannerId,
    bool isActive,
  );

  // Promotional Images
  Future<Either<Failure, List<PromotionalImageEntity>>>
  getAllPromotionalImages();
  Future<Either<Failure, List<PromotionalImageEntity>>>
  getActivePromotionalImages();
  Future<Either<Failure, PromotionalImageEntity>> getPromotionalImageById(
    String imageId,
  );
  Future<Either<Failure, PromotionalImageEntity>> createPromotionalImage(
    PromotionalImageEntity image,
  );
  Future<Either<Failure, void>> updatePromotionalImage(
    PromotionalImageEntity image,
  );
  Future<Either<Failure, void>> deletePromotionalImage(String imageId);
  Future<Either<Failure, void>> togglePromotionalImageStatus(
    String imageId,
    bool isActive,
  );
}
