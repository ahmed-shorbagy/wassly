import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../../core/utils/logger.dart';
import '../../../restaurants/domain/entities/restaurant_category_entity.dart';
import '../../../restaurants/domain/repositories/restaurant_category_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore firestore;
  final RestaurantCategoryRepository _categoryRepository;

  HomeCubit({
    FirebaseFirestore? firestoreInstance,
    required RestaurantCategoryRepository categoryRepository,
  }) : firestore = firestoreInstance ?? FirebaseFirestore.instance,
       _categoryRepository = categoryRepository,
       super(HomeInitial());

  Future<void> loadHome() async {
    try {
      emit(HomeLoading());
      final banners = await _loadBanners();
      final categoriesResult = await _categoryRepository.getCategories();

      categoriesResult.fold(
        (failure) {
          AppLogger.logError(
            'Failed to load categories',
            error: failure.message,
          );
          emit(HomeLoaded(banners: banners, categories: const []));
        },
        (categories) =>
            emit(HomeLoaded(banners: banners, categories: categories)),
      );
    } catch (e) {
      AppLogger.logError('Failed to load home', error: e);
      emit(const HomeError('Failed to load home data'));
    }
  }

  Future<List<BannerEntity>> _loadBanners() async {
    try {
      QuerySnapshot snapshot;
      try {
        // Try with isActive filter and priority order (requires composite index)
        snapshot = await firestore
            .collection('banners')
            .where('isActive', isEqualTo: true)
            .orderBy('priority', descending: false)
            .get();
      } catch (e) {
        // Fallback: fetch all and filter client-side
        AppLogger.logWarning(
          'Banner query with filters failed, using fallback: $e',
        );
        snapshot = await firestore
            .collection('banners')
            .orderBy('priority', descending: false)
            .get();
      }

      final banners = snapshot.docs
          .map((d) {
            final data = d.data() as Map<String, dynamic>;
            // Filter active banners client-side if query didn't include filter
            final isActive = data['isActive'] ?? true;
            if (!isActive) return null;

            return BannerEntity(
              id: d.id,
              imageUrl: (data['imageUrl'] ?? '') as String,
              title: data['title'] as String?,
              deepLink: data['deepLink'] as String?,
              type: (data['type'] ?? 'home') as String,
            );
          })
          .where((b) => b != null && b.imageUrl.isNotEmpty)
          .cast<BannerEntity>()
          .toList();

      return banners;
    } catch (e) {
      AppLogger.logError('Failed to fetch banners', error: e);
      return [];
    }
  }
}
