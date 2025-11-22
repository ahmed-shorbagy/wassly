import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';

part 'delivery_address_state.dart';

/// Cubit to manage user's selected delivery address
/// Stores address in SharedPreferences for persistence
class DeliveryAddressCubit extends Cubit<DeliveryAddressState> {
  static const String _addressKey = 'selected_delivery_address';
  static const String _addressLabelKey = 'selected_delivery_address_label';

  DeliveryAddressCubit() : super(DeliveryAddressInitial()) {
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString(_addressKey);
      final savedLabel = prefs.getString(_addressLabelKey);

      if (savedAddress != null && savedAddress.isNotEmpty) {
        emit(DeliveryAddressSelected(
          address: savedAddress,
          addressLabel: savedLabel,
        ));
      } else {
        emit(DeliveryAddressNotSet());
      }
    } catch (e) {
      AppLogger.logError('Failed to load saved address', error: e);
      emit(DeliveryAddressNotSet());
    }
  }

  Future<void> setDeliveryAddress({
    required String address,
    String? addressLabel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_addressKey, address);
      if (addressLabel != null && addressLabel.isNotEmpty) {
        await prefs.setString(_addressLabelKey, addressLabel);
      } else {
        await prefs.remove(_addressLabelKey);
      }
      
      emit(DeliveryAddressSelected(
        address: address,
        addressLabel: addressLabel,
      ));
      
      AppLogger.logInfo('Delivery address saved: $address');
    } catch (e) {
      AppLogger.logError('Failed to save delivery address', error: e);
      emit(DeliveryAddressError('Failed to save address'));
    }
  }

  Future<void> clearDeliveryAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_addressKey);
      await prefs.remove(_addressLabelKey);
      
      emit(DeliveryAddressNotSet());
      AppLogger.logInfo('Delivery address cleared');
    } catch (e) {
      AppLogger.logError('Failed to clear delivery address', error: e);
      emit(DeliveryAddressError('Failed to clear address'));
    }
  }
}

