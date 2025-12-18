import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/startup_ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

part 'startup_ad_customer_state.dart';

class StartupAdCustomerCubit extends Cubit<StartupAdCustomerState> {
  final AdRepository repository;
  static const String _lastShownAdKey = 'last_shown_startup_ad_id';

  StartupAdCustomerCubit({required this.repository})
      : super(StartupAdCustomerInitial());

  Future<void> loadActiveStartupAds() async {
    try {
      emit(StartupAdCustomerLoading());
      AppLogger.logInfo('Loading active startup ads for customer');

      final result = await repository.getAllStartupAds();

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to load startup ads',
            error: failure.message,
          );
          emit(StartupAdCustomerError(failure.message));
        },
        (ads) async {
          // Filter only active ads
          final activeAds = ads.where((ad) => ad.isActive).toList();
          
          if (activeAds.isEmpty) {
            emit(StartupAdCustomerLoaded([]));
            return;
          }
          
          // Get the last shown ad ID from preferences
          final prefs = await SharedPreferences.getInstance();
          final lastShownAdId = prefs.getString(_lastShownAdKey);
          
          // Filter out the last shown ad if it exists and there are other ads available
          List<StartupAdEntity> adsToShow = activeAds;
          if (lastShownAdId != null && activeAds.length > 1) {
            adsToShow = activeAds.where((ad) => ad.id != lastShownAdId).toList();
            
            // If filtering removed all ads (shouldn't happen, but safety check)
            if (adsToShow.isEmpty) {
              adsToShow = activeAds;
            }
            
            AppLogger.logInfo(
              'Excluded last shown ad: $lastShownAdId. Available ads: ${adsToShow.length}',
            );
          }
          
          // Shuffle ads to randomize order for display
          // This ensures customers see different ads each time they open the app
          adsToShow.shuffle(Random());
          
          AppLogger.logSuccess(
            'Startup ads loaded and randomized: ${adsToShow.length} (total active: ${activeAds.length})',
          );
          emit(StartupAdCustomerLoaded(adsToShow));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading startup ads', error: e);
      emit(StartupAdCustomerError('Failed to load startup ads: $e'));
    }
  }

  /// Save the ad ID that was shown to the user
  /// This will be used to exclude it from the next session
  Future<void> saveShownAdId(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastShownAdKey, adId);
      AppLogger.logInfo('Saved last shown startup ad ID: $adId');
    } catch (e) {
      AppLogger.logError('Error saving last shown ad ID', error: e);
    }
  }
}

