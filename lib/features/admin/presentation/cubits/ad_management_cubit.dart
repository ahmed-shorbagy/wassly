import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../ads/domain/entities/startup_ad_entity.dart';
import '../../../ads/domain/repositories/ad_repository.dart';
import '../../../home/domain/entities/banner_entity.dart';

part 'ad_management_state.dart';

class AdManagementCubit extends Cubit<AdManagementState> {
  final AdRepository repository;

  AdManagementCubit({required this.repository}) : super(AdManagementInitial());

  // Startup Ads
  Future<void> loadAllStartupAds() async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Loading all startup ads');

      final result = await repository.getAllStartupAds();

      result.fold(
        (failure) {
          AppLogger.logError('Failed to load startup ads', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (ads) {
          AppLogger.logSuccess('Startup ads loaded: ${ads.length}');
          emit(StartupAdsLoaded(ads));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading startup ads', error: e);
      emit(AdManagementError('Failed to load startup ads: $e'));
    }
  }

  Future<void> addStartupAd({
    required String imageUrl,
    String? title,
    String? description,
    String? deepLink,
    String? restaurantId,
    String? restaurantName,
    required File? imageFile,
    bool isActive = true,
    int priority = 0,
  }) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Adding startup ad');

      String? finalImageUrl = imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'startup_ads',
        );
        final result = uploadResult.fold(
          (failure) {
            emit(AdManagementError('Failed to upload image: ${failure.message}'));
            return null as String?;
          },
          (url) => url,
        );
        if (result == null) return;
        finalImageUrl = result;
      }

      final ad = StartupAdEntity(
        id: '',
        imageUrl: finalImageUrl,
        title: title,
        description: description,
        deepLink: deepLink,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        isActive: isActive,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createStartupAd(ad);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to add startup ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (createdAd) {
          AppLogger.logSuccess('Startup ad added: ${createdAd.id}');
          emit(StartupAdAdded(createdAd));
          loadAllStartupAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error adding startup ad', error: e);
      emit(AdManagementError('Failed to add startup ad: $e'));
    }
  }

  Future<void> updateStartupAd({
    required String adId,
    required String imageUrl,
    String? title,
    String? description,
    String? deepLink,
    String? restaurantId,
    String? restaurantName,
    File? imageFile,
    bool? isActive,
    int? priority,
  }) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Updating startup ad: $adId');

      String? finalImageUrl = imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'startup_ads',
        );
        final result = uploadResult.fold(
          (failure) {
            emit(AdManagementError('Failed to upload image: ${failure.message}'));
            return null as String?;
          },
          (url) => url,
        );
        if (result == null) return;
        finalImageUrl = result;
      }

      // Get existing ad to preserve fields
      final existingResult = await repository.getStartupAdById(adId);
      StartupAdEntity? existingAd;
      final existingAdResult = existingResult.fold(
        (failure) {
          emit(AdManagementError('Failed to get existing ad'));
          return null as StartupAdEntity?;
        },
        (ad) => ad,
      );
      if (existingAdResult == null) return;
      existingAd = existingAdResult;

      final ad = StartupAdEntity(
        id: adId,
        imageUrl: finalImageUrl,
        title: title ?? existingAd.title,
        description: description ?? existingAd.description,
        deepLink: deepLink ?? existingAd.deepLink,
        restaurantId: restaurantId ?? existingAd.restaurantId,
        restaurantName: restaurantName ?? existingAd.restaurantName,
        isActive: isActive ?? existingAd.isActive,
        priority: priority ?? existingAd.priority,
        createdAt: existingAd.createdAt,
        updatedAt: DateTime.now(),
      );

      final updateResult = await repository.updateStartupAd(ad);

      updateResult.fold(
        (failure) {
          AppLogger.logError('Failed to update startup ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Startup ad updated: $adId');
          emit(StartupAdUpdated());
          loadAllStartupAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating startup ad', error: e);
      emit(AdManagementError('Failed to update startup ad: $e'));
    }
  }

  Future<void> deleteStartupAd(String adId) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Deleting startup ad: $adId');

      final result = await repository.deleteStartupAd(adId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete startup ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Startup ad deleted: $adId');
          emit(StartupAdDeleted());
          loadAllStartupAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting startup ad', error: e);
      emit(AdManagementError('Failed to delete startup ad: $e'));
    }
  }

  Future<void> toggleStartupAdStatus(String adId, bool isActive) async {
    try {
      AppLogger.logInfo('Toggling startup ad status: $adId');

      final result = await repository.toggleStartupAdStatus(adId, isActive);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to toggle status', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Startup ad status updated');
          emit(StartupAdStatusToggled());
          loadAllStartupAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error toggling status', error: e);
      emit(AdManagementError('Failed to update status: $e'));
    }
  }

  // Banner Ads
  Future<void> loadAllBannerAds() async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Loading all banner ads');

      final result = await repository.getAllBannerAds();

      result.fold(
        (failure) {
          AppLogger.logError('Failed to load banner ads', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (banners) {
          AppLogger.logSuccess('Banner ads loaded: ${banners.length}');
          emit(BannerAdsLoaded(banners));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading banner ads', error: e);
      emit(AdManagementError('Failed to load banner ads: $e'));
    }
  }

  Future<void> addBannerAd({
    required String imageUrl,
    String? title,
    String? deepLink,
    required File? imageFile,
    int priority = 0,
  }) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Adding banner ad');

      String? finalImageUrl = imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'banners',
        );
        final result = uploadResult.fold(
          (failure) {
            emit(AdManagementError('Failed to upload image: ${failure.message}'));
            return null as String?;
          },
          (url) => url,
        );
        if (result == null) return;
        finalImageUrl = result;
      }

      final banner = BannerEntity(
        id: '',
        imageUrl: finalImageUrl,
        title: title,
        deepLink: deepLink,
      );

      final result = await repository.createBannerAd(banner);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to add banner ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (createdBanner) {
          AppLogger.logSuccess('Banner ad added: ${createdBanner.id}');
          emit(BannerAdAdded(createdBanner));
          loadAllBannerAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error adding banner ad', error: e);
      emit(AdManagementError('Failed to add banner ad: $e'));
    }
  }

  Future<void> updateBannerAd({
    required String bannerId,
    required String imageUrl,
    String? title,
    String? deepLink,
    File? imageFile,
    int? priority,
  }) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Updating banner ad: $bannerId');

      String? finalImageUrl = imageUrl;
      if (imageFile != null) {
        final uploadResult = await repository.uploadImageFile(
          imageFile,
          SupabaseConstants.restaurantImagesBucket,
          'banners',
        );
        final result = uploadResult.fold(
          (failure) {
            emit(AdManagementError('Failed to upload image: ${failure.message}'));
            return null as String?;
          },
          (url) => url,
        );
        if (result == null) return;
        finalImageUrl = result;
      }

      final banner = BannerEntity(
        id: bannerId,
        imageUrl: finalImageUrl,
        title: title,
        deepLink: deepLink,
      );

      final result = await repository.updateBannerAd(banner);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to update banner ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Banner ad updated: $bannerId');
          emit(BannerAdUpdated());
          loadAllBannerAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating banner ad', error: e);
      emit(AdManagementError('Failed to update banner ad: $e'));
    }
  }

  Future<void> deleteBannerAd(String bannerId) async {
    try {
      emit(AdManagementLoading());
      AppLogger.logInfo('Deleting banner ad: $bannerId');

      final result = await repository.deleteBannerAd(bannerId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete banner ad', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Banner ad deleted: $bannerId');
          emit(BannerAdDeleted());
          loadAllBannerAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting banner ad', error: e);
      emit(AdManagementError('Failed to delete banner ad: $e'));
    }
  }

  Future<void> toggleBannerAdStatus(String bannerId, bool isActive) async {
    try {
      AppLogger.logInfo('Toggling banner ad status: $bannerId');

      final result = await repository.toggleBannerAdStatus(bannerId, isActive);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to toggle status', error: failure.message);
          emit(AdManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Banner ad status updated');
          emit(BannerAdStatusToggled());
          loadAllBannerAds();
        },
      );
    } catch (e) {
      AppLogger.logError('Error toggling status', error: e);
      emit(AdManagementError('Failed to update status: $e'));
    }
  }
}

