import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/startup_ad_entity.dart';
import '../../domain/repositories/ad_repository.dart';

part 'startup_ad_customer_state.dart';

class StartupAdCustomerCubit extends Cubit<StartupAdCustomerState> {
  final AdRepository repository;

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
        (ads) {
          // Filter only active ads and sort by priority
          final activeAds = ads
              .where((ad) => ad.isActive)
              .toList()
            ..sort((a, b) => a.priority.compareTo(b.priority));
          AppLogger.logSuccess(
            'Startup ads loaded: ${activeAds.length}',
          );
          emit(StartupAdCustomerLoaded(activeAds));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading startup ads', error: e);
      emit(StartupAdCustomerError('Failed to load startup ads: $e'));
    }
  }
}

