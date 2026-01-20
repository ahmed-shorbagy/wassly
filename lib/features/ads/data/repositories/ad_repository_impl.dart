import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../domain/entities/startup_ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';
import '../models/startup_ad_model.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../home/data/models/banner_model.dart';
import '../../../home/domain/entities/promotional_image_entity.dart';
import '../../../home/data/models/promotional_image_model.dart';

class AdRepositoryImpl implements AdRepository {
  final FirebaseFirestore firestore;
  final ImageUploadHelper imageUploadHelper;

  AdRepositoryImpl({required this.firestore, required this.imageUploadHelper});

  @override
  Future<Either<Failure, String>> uploadImageFile(
    File file,
    String bucketName,
    String folder,
  ) async {
    try {
      AppLogger.logInfo('Uploading image to $bucketName/$folder');
      final result = await imageUploadHelper.uploadFile(
        file: file,
        bucketName: bucketName,
        folder: folder,
      );
      return result.fold((failure) => Left(failure), (url) {
        AppLogger.logSuccess('Image uploaded successfully');
        return Right(url);
      });
    } catch (e) {
      AppLogger.logError('Error uploading image', error: e);
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  // Startup Ads
  @override
  Future<Either<Failure, List<StartupAdEntity>>> getAllStartupAds() async {
    try {
      AppLogger.logInfo('Fetching all startup ads');
      QuerySnapshot snapshot;
      try {
        snapshot = await firestore
            .collection('startup_ads')
            .orderBy('priority', descending: false)
            .get();
      } catch (e) {
        // Fallback if priority index doesn't exist
        AppLogger.logWarning(
          'Startup ads query with orderBy failed, using fallback: $e',
        );
        snapshot = await firestore.collection('startup_ads').get();
      }

      final ads =
          snapshot.docs.map((doc) => StartupAdModel.fromFirestore(doc)).toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));

      AppLogger.logSuccess('Fetched ${ads.length} startup ads');
      return Right(ads);
    } catch (e) {
      AppLogger.logError('Error fetching startup ads', error: e);
      return Left(ServerFailure('Failed to fetch startup ads: $e'));
    }
  }

  @override
  Future<Either<Failure, StartupAdEntity>> getStartupAdById(String adId) async {
    try {
      AppLogger.logInfo('Fetching startup ad: $adId');
      final doc = await firestore.collection('startup_ads').doc(adId).get();

      if (!doc.exists) {
        return const Left(CacheFailure('Startup ad not found'));
      }

      final ad = StartupAdModel.fromFirestore(doc);
      AppLogger.logSuccess('Startup ad fetched successfully');
      return Right(ad);
    } catch (e) {
      AppLogger.logError('Error fetching startup ad', error: e);
      return Left(ServerFailure('Failed to fetch startup ad: $e'));
    }
  }

  @override
  Future<Either<Failure, StartupAdEntity>> createStartupAd(
    StartupAdEntity ad,
  ) async {
    try {
      AppLogger.logInfo('Creating startup ad');
      final model = StartupAdModel.fromEntity(ad);
      final docRef = await firestore
          .collection('startup_ads')
          .add(model.toFirestore());

      final createdAd = StartupAdModel(
        id: docRef.id,
        imageUrl: ad.imageUrl,
        title: ad.title,
        description: ad.description,
        deepLink: ad.deepLink,
        isActive: ad.isActive,
        priority: ad.priority,
        createdAt: ad.createdAt,
        updatedAt: ad.updatedAt,
      );

      AppLogger.logSuccess('Startup ad created: ${docRef.id}');
      return Right(createdAd);
    } catch (e) {
      AppLogger.logError('Error creating startup ad', error: e);
      return Left(ServerFailure('Failed to create startup ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStartupAd(StartupAdEntity ad) async {
    try {
      AppLogger.logInfo('Updating startup ad: ${ad.id}');
      final model = StartupAdModel.fromEntity(ad);
      await firestore
          .collection('startup_ads')
          .doc(ad.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Startup ad updated: ${ad.id}');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error updating startup ad', error: e);
      return Left(ServerFailure('Failed to update startup ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStartupAd(String adId) async {
    try {
      AppLogger.logInfo('Deleting startup ad: $adId');
      await firestore.collection('startup_ads').doc(adId).delete();
      AppLogger.logSuccess('Startup ad deleted: $adId');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error deleting startup ad', error: e);
      return Left(ServerFailure('Failed to delete startup ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStartupAdStatus(
    String adId,
    bool isActive,
  ) async {
    try {
      AppLogger.logInfo('Toggling startup ad status: $adId');
      await firestore.collection('startup_ads').doc(adId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.logSuccess('Startup ad status updated');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error toggling startup ad status', error: e);
      return Left(ServerFailure('Failed to update startup ad status: $e'));
    }
  }

  // Banner Ads
  @override
  Future<Either<Failure, List<BannerEntity>>> getAllBannerAds() async {
    try {
      AppLogger.logInfo('Fetching all banner ads');
      QuerySnapshot snapshot;
      try {
        snapshot = await firestore
            .collection('banners')
            .orderBy('priority', descending: false)
            .get();
      } catch (e) {
        // Fallback if priority index doesn't exist
        AppLogger.logWarning(
          'Banner ads query with orderBy failed, using fallback: $e',
        );
        snapshot = await firestore.collection('banners').get();
      }

      final banners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .where((b) => b.imageUrl.isNotEmpty)
          .toList();

      // Sort by priority client-side
      banners.sort((a, b) {
        final aPriority = a.priority ?? 0;
        final bPriority = b.priority ?? 0;
        return aPriority.compareTo(bPriority);
      });

      AppLogger.logSuccess('Fetched ${banners.length} banner ads');
      return Right(banners);
    } catch (e) {
      AppLogger.logError('Error fetching banner ads', error: e);
      return Left(ServerFailure('Failed to fetch banner ads: $e'));
    }
  }

  @override
  Future<Either<Failure, BannerEntity>> getBannerAdById(String bannerId) async {
    try {
      AppLogger.logInfo('Fetching banner ad: $bannerId');
      final doc = await firestore.collection('banners').doc(bannerId).get();

      if (!doc.exists) {
        return const Left(CacheFailure('Banner ad not found'));
      }

      final banner = BannerModel.fromFirestore(doc);
      AppLogger.logSuccess('Banner ad fetched successfully');
      return Right(banner);
    } catch (e) {
      AppLogger.logError('Error fetching banner ad', error: e);
      return Left(ServerFailure('Failed to fetch banner ad: $e'));
    }
  }

  @override
  Future<Either<Failure, BannerEntity>> createBannerAd(
    BannerEntity banner,
  ) async {
    try {
      AppLogger.logInfo('Creating banner ad');
      final model = BannerModel.fromEntity(banner);
      final docRef = await firestore
          .collection('banners')
          .add(model.toFirestore());

      final createdBanner = BannerModel(
        id: docRef.id,
        imageUrl: banner.imageUrl,
        title: banner.title,
        deepLink: banner.deepLink,
        type: banner.type,
        isActive: true,
        priority: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.logSuccess('Banner ad created: ${docRef.id}');
      return Right(createdBanner);
    } catch (e) {
      AppLogger.logError('Error creating banner ad', error: e);
      return Left(ServerFailure('Failed to create banner ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBannerAd(BannerEntity banner) async {
    try {
      AppLogger.logInfo('Updating banner ad: ${banner.id}');
      final existingDoc = await firestore
          .collection('banners')
          .doc(banner.id)
          .get();
      final existingData = existingDoc.data();

      final model = BannerModel(
        id: banner.id,
        imageUrl: banner.imageUrl,
        title: banner.title,
        deepLink: banner.deepLink,
        type: banner.type,
        isActive: existingData?['isActive'] ?? true,
        priority: existingData?['priority'] ?? 0,
        createdAt: existingData?['createdAt'] is Timestamp
            ? (existingData!['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection('banners')
          .doc(banner.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Banner ad updated: ${banner.id}');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error updating banner ad', error: e);
      return Left(ServerFailure('Failed to update banner ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBannerAd(String bannerId) async {
    try {
      AppLogger.logInfo('Deleting banner ad: $bannerId');
      await firestore.collection('banners').doc(bannerId).delete();
      AppLogger.logSuccess('Banner ad deleted: $bannerId');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error deleting banner ad', error: e);
      return Left(ServerFailure('Failed to delete banner ad: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBannerAdStatus(
    String bannerId,
    bool isActive,
  ) async {
    try {
      AppLogger.logInfo('Toggling banner ad status: $bannerId');
      await firestore.collection('banners').doc(bannerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.logSuccess('Banner ad status updated');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error toggling banner ad status', error: e);
      return Left(ServerFailure('Failed to update banner ad status: $e'));
    }
  }

  // Promotional Images
  @override
  Future<Either<Failure, List<PromotionalImageEntity>>>
  getAllPromotionalImages() async {
    try {
      AppLogger.logInfo('Fetching all promotional images');
      QuerySnapshot snapshot;
      try {
        snapshot = await firestore
            .collection('promotional_images')
            .orderBy('priority', descending: false)
            .get();
      } catch (e) {
        // Fallback if priority index doesn't exist
        AppLogger.logWarning(
          'Promotional images query with orderBy failed, using fallback: $e',
        );
        snapshot = await firestore.collection('promotional_images').get();
      }

      final images = snapshot.docs
          .map((doc) => PromotionalImageModel.fromFirestore(doc))
          .where((img) => img.imageUrl.isNotEmpty)
          .toList();

      // Sort by priority client-side
      images.sort((a, b) => a.priority.compareTo(b.priority));

      AppLogger.logSuccess('Fetched ${images.length} promotional images');
      return Right(images);
    } catch (e) {
      AppLogger.logError('Error fetching promotional images', error: e);
      return Left(ServerFailure('Failed to fetch promotional images: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PromotionalImageEntity>>>
  getActivePromotionalImages() async {
    try {
      AppLogger.logInfo('Fetching active promotional images');
      QuerySnapshot snapshot;
      try {
        snapshot = await firestore
            .collection('promotional_images')
            .where('isActive', isEqualTo: true)
            .orderBy('priority', descending: false)
            .get();
      } catch (e) {
        // Fallback: fetch all and filter client-side
        AppLogger.logWarning(
          'Promotional images query with filters failed, using fallback: $e',
        );
        snapshot = await firestore.collection('promotional_images').get();
      }

      final images = snapshot.docs
          .map((doc) => PromotionalImageModel.fromFirestore(doc))
          .where((img) => img.imageUrl.isNotEmpty && img.isActive)
          .toList();

      // Sort by priority client-side
      images.sort((a, b) => a.priority.compareTo(b.priority));

      AppLogger.logSuccess(
        'Fetched ${images.length} active promotional images',
      );
      return Right(images);
    } catch (e) {
      AppLogger.logError('Error fetching active promotional images', error: e);
      return Left(ServerFailure('Failed to fetch promotional images: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionalImageEntity>> getPromotionalImageById(
    String imageId,
  ) async {
    try {
      AppLogger.logInfo('Fetching promotional image: $imageId');
      final doc = await firestore
          .collection('promotional_images')
          .doc(imageId)
          .get();

      if (!doc.exists) {
        return const Left(CacheFailure('Promotional image not found'));
      }

      final image = PromotionalImageModel.fromFirestore(doc);
      AppLogger.logSuccess('Promotional image fetched successfully');
      return Right(image);
    } catch (e) {
      AppLogger.logError('Error fetching promotional image', error: e);
      return Left(ServerFailure('Failed to fetch promotional image: $e'));
    }
  }

  @override
  Future<Either<Failure, PromotionalImageEntity>> createPromotionalImage(
    PromotionalImageEntity image,
  ) async {
    try {
      AppLogger.logInfo('Creating promotional image');
      final model = PromotionalImageModel.fromEntity(image);
      final docRef = await firestore
          .collection('promotional_images')
          .add(model.toFirestore());

      final createdImage = PromotionalImageModel(
        id: docRef.id,
        imageUrl: image.imageUrl,
        title: image.title,
        subtitle: image.subtitle,
        deepLink: image.deepLink,
        isActive: image.isActive,
        priority: image.priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.logSuccess('Promotional image created: ${docRef.id}');
      return Right(createdImage);
    } catch (e) {
      AppLogger.logError('Error creating promotional image', error: e);
      return Left(ServerFailure('Failed to create promotional image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePromotionalImage(
    PromotionalImageEntity image,
  ) async {
    try {
      AppLogger.logInfo('Updating promotional image: ${image.id}');
      final model = PromotionalImageModel.fromEntity(image);
      await firestore
          .collection('promotional_images')
          .doc(image.id)
          .update(model.toFirestore());

      AppLogger.logSuccess('Promotional image updated: ${image.id}');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error updating promotional image', error: e);
      return Left(ServerFailure('Failed to update promotional image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePromotionalImage(String imageId) async {
    try {
      AppLogger.logInfo('Deleting promotional image: $imageId');
      await firestore.collection('promotional_images').doc(imageId).delete();
      AppLogger.logSuccess('Promotional image deleted: $imageId');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error deleting promotional image', error: e);
      return Left(ServerFailure('Failed to delete promotional image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> togglePromotionalImageStatus(
    String imageId,
    bool isActive,
  ) async {
    try {
      AppLogger.logInfo('Toggling promotional image status: $imageId');
      await firestore.collection('promotional_images').doc(imageId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.logSuccess('Promotional image status updated');
      return const Right(null);
    } catch (e) {
      AppLogger.logError('Error toggling promotional image status', error: e);
      return Left(
        ServerFailure('Failed to update promotional image status: $e'),
      );
    }
  }
}
