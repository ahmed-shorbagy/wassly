import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../../restaurants/domain/repositories/restaurant_owner_repository.dart';

part 'product_management_state.dart';

class ProductManagementCubit extends Cubit<ProductManagementState> {
  final RestaurantOwnerRepository repository;

  ProductManagementCubit({required this.repository})
      : super(ProductManagementInitial());

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      AppLogger.logInfo('Toggling product availability: $productId');

      final result = await repository.toggleProductAvailability(
        productId,
        isAvailable,
      );

      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to toggle availability',
            error: failure.message,
          );
          emit(ProductManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Product availability updated');
          emit(ProductAvailabilityToggled());
        },
      );
    } catch (e) {
      AppLogger.logError('Error toggling availability', error: e);
      emit(const ProductManagementError('Failed to update availability'));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      emit(ProductManagementLoading());
      AppLogger.logInfo('Deleting product: $productId');

      final result = await repository.deleteProduct(productId);

      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete product', error: failure.message);
          emit(ProductManagementError(failure.message));
        },
        (_) {
          AppLogger.logSuccess('Product deleted successfully');
          emit(ProductDeleted());
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting product', error: e);
      emit(const ProductManagementError('Failed to delete product'));
    }
  }
}

