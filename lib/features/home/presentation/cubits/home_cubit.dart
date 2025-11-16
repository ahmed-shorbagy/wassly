import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../../core/utils/logger.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore firestore;

  HomeCubit({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance,
        super(HomeInitial());

  Future<void> loadHome() async {
    try {
      emit(HomeLoading());
      final banners = await _loadBanners();
      emit(HomeLoaded(banners: banners));
    } catch (e) {
      AppLogger.logError('Failed to load home', error: e);
      emit(const HomeError('Failed to load home data'));
    }
  }

  Future<List<BannerEntity>> _loadBanners() async {
    try {
      final snapshot = await firestore
          .collection('banners')
          .orderBy('priority', descending: false)
          .get();
      return snapshot.docs
          .map((d) => BannerEntity(
                id: d.id,
                imageUrl: (d.data()['imageUrl'] ?? '') as String,
                title: d.data()['title'] as String?,
                deepLink: d.data()['deepLink'] as String?,
              ))
          .where((b) => b.imageUrl.isNotEmpty)
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch banners', error: e);
      return [];
    }
  }
}


