import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/market_product_entity.dart';
import '../../domain/repositories/market_product_repository.dart';

part 'market_product_customer_state.dart';

class MarketProductCustomerCubit extends Cubit<MarketProductCustomerState> {
  final MarketProductRepository repository;

  MarketProductCustomerCubit({required this.repository})
    : super(MarketProductCustomerInitial());

  Future<void> loadMarketProducts({String? restaurantId}) async {
    try {
      emit(MarketProductCustomerLoading());
      if (restaurantId != null) {
        AppLogger.logInfo(
          'Loading market products for restaurant: $restaurantId',
        );
      } else {
        AppLogger.logInfo('Loading market products for customer');
      }

      final result = restaurantId != null
          ? await repository.getMarketProductsByRestaurantId(restaurantId)
          : await repository.getAllMarketProducts();

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to load market products',
            error: failure.message,
          );
          emit(MarketProductCustomerError(failure.message));
        },
        (products) {
          // Filter only available products
          final availableProducts = products
              .where((p) => p.isAvailable)
              .toList();
          AppLogger.logSuccess(
            'Market products loaded: ${availableProducts.length}',
          );
          emit(MarketProductCustomerLoaded(availableProducts));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading market products', error: e);
      emit(MarketProductCustomerError('Failed to load market products: $e'));
    }
  }
}
