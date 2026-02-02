import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/repositories/delivery_address_repository.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../data/models/delivery_address_model.dart';

part 'delivery_address_state.dart';

/// Cubit to manage user's delivery addresses
/// Supports multiple addresses with selection and real-time sync
class DeliveryAddressCubit extends Cubit<DeliveryAddressState> {
  final DeliveryAddressRepository repository;
  final AuthCubit authCubit;
  
  String? _currentUserId;
  StreamSubscription? _addressStreamSubscription;
  StreamSubscription? _addressesListStreamSubscription;
  List<DeliveryAddressEntity> _allAddresses = [];

  DeliveryAddressCubit({
    required this.repository,
    required this.authCubit,
  }) : super(DeliveryAddressInitial()) {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes to get user ID
    authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        _currentUserId = authState.user.id;
        _loadAddressFromFirebase();
        loadAllAddresses();
        _subscribeToAddressStream();
        _subscribeToAddressesListStream();
      } else {
        _currentUserId = null;
        _addressStreamSubscription?.cancel();
        _addressesListStreamSubscription?.cancel();
        _allAddresses = [];
        emit(DeliveryAddressNotSet());
      }
    });

    // Check current auth state
    final currentAuthState = authCubit.state;
    if (currentAuthState is AuthAuthenticated) {
      _currentUserId = currentAuthState.user.id;
      _loadAddressFromFirebase();
      loadAllAddresses();
      _subscribeToAddressStream();
      _subscribeToAddressesListStream();
    } else {
      emit(DeliveryAddressNotSet());
    }
  }

  Future<void> loadAllAddresses() async {
    if (_currentUserId == null) return;

    try {
      final result = await repository.getAllDeliveryAddresses(_currentUserId!);
      result.fold(
        (failure) {
          AppLogger.logError('Failed to load addresses', error: failure.message);
        },
        (addresses) {
          _allAddresses = addresses;
          final defaultAddresses = addresses.where((a) => a.isDefault).toList();
          final selected = defaultAddresses.isNotEmpty ? defaultAddresses.first : null;
          emit(DeliveryAddressesLoaded(
            addresses: addresses,
            selectedAddress: selected,
          ));
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading addresses', error: e);
    }
  }

  void _subscribeToAddressesListStream() {
    if (_currentUserId == null) return;

    _addressesListStreamSubscription?.cancel();
    
    _addressesListStreamSubscription = repository
        .streamAllDeliveryAddresses(_currentUserId!)
        .listen(
      (addresses) {
        _allAddresses = addresses;
        final selected = addresses.where((a) => a.isDefault).firstOrNull;
        emit(DeliveryAddressesLoaded(
          addresses: addresses,
          selectedAddress: selected,
        ));
      },
      onError: (error) {
        AppLogger.logError('Error in addresses list stream', error: error);
      },
    );
  }

  Future<void> _loadAddressFromFirebase() async {
    if (_currentUserId == null) {
      emit(DeliveryAddressNotSet());
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.getCurrentDeliveryAddress(_currentUserId!);
      
      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to load delivery address',
            error: failure.message,
          );
          emit(DeliveryAddressError(failure.message));
        },
        (address) {
          if (address != null) {
            emit(DeliveryAddressSelected(
              address: address.fullAddress,
              addressLabel: address.addressLabel,
              addressId: address.id,
            ));
          } else {
            emit(DeliveryAddressNotSet());
          }
        },
      );
    } catch (e) {
      AppLogger.logError('Error loading delivery address', error: e);
      emit(DeliveryAddressError('Failed to load address'));
    }
  }

  void _subscribeToAddressStream() {
    if (_currentUserId == null) return;

    _addressStreamSubscription?.cancel();
    
    _addressStreamSubscription = repository
        .streamCurrentDeliveryAddress(_currentUserId!)
        .listen(
      (address) {
        if (address != null) {
          emit(DeliveryAddressSelected(
            address: address.fullAddress,
            addressLabel: address.addressLabel,
            addressId: address.id,
          ));
          // Update all addresses list if needed
          final updatedAddresses = _allAddresses.map((a) {
            if (a.id == address.id) {
              return address;
            } else if (a.isDefault) {
              return DeliveryAddressModel.fromEntity(a).copyWith(
                isDefault: false,
              );
            }
            return a;
          }).toList();
          _allAddresses = updatedAddresses;
          emit(DeliveryAddressesLoaded(
            addresses: updatedAddresses,
            selectedAddress: address,
          ));
        } else {
          emit(DeliveryAddressNotSet());
        }
      },
      onError: (error) {
        AppLogger.logError('Error in address stream', error: error);
        emit(DeliveryAddressError('Failed to sync address'));
      },
    );
  }

  Future<void> setDeliveryAddress({
    required String address,
    String? addressLabel,
  }) async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.setCurrentDeliveryAddress(
        _currentUserId!,
        address,
        addressLabel,
      );
      
      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to save delivery address',
            error: failure.message,
          );
          emit(DeliveryAddressError(failure.message));
          // Try to reload current address
          _loadAddressFromFirebase();
        },
        (_) {
          AppLogger.logInfo('Delivery address saved: $address');
          // State will be updated via stream
        },
      );
    } catch (e) {
      AppLogger.logError('Error saving delivery address', error: e);
      emit(DeliveryAddressError('Failed to save address'));
    }
  }

  Future<void> clearDeliveryAddress() async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.clearCurrentDeliveryAddress(_currentUserId!);
      
      result.fold(
        (failure) {
          AppLogger.logError(
            'Failed to clear delivery address',
            error: failure.message,
          );
          emit(DeliveryAddressError(failure.message));
        },
        (_) {
          AppLogger.logInfo('Delivery address cleared');
          emit(DeliveryAddressNotSet());
        },
      );
    } catch (e) {
      AppLogger.logError('Error clearing delivery address', error: e);
      emit(DeliveryAddressError('Failed to clear address'));
    }
  }

  Future<void> addAddress(DeliveryAddressEntity address) async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.addDeliveryAddress(
        _currentUserId!,
        address,
      );
      
      result.fold(
        (failure) {
          AppLogger.logError('Failed to add address', error: failure.message);
          emit(DeliveryAddressError(failure.message));
          loadAllAddresses();
        },
        (addedAddress) {
          AppLogger.logInfo('Address added: ${addedAddress.id}');
          // State will be updated via stream
        },
      );
    } catch (e) {
      AppLogger.logError('Error adding address', error: e);
      emit(DeliveryAddressError('Failed to add address'));
    }
  }

  Future<void> updateAddress(DeliveryAddressEntity address) async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.updateDeliveryAddress(
        _currentUserId!,
        address,
      );
      
      result.fold(
        (failure) {
          AppLogger.logError('Failed to update address', error: failure.message);
          emit(DeliveryAddressError(failure.message));
          loadAllAddresses();
        },
        (_) {
          AppLogger.logInfo('Address updated: ${address.id}');
          // State will be updated via stream
        },
      );
    } catch (e) {
      AppLogger.logError('Error updating address', error: e);
      emit(DeliveryAddressError('Failed to update address'));
    }
  }

  Future<void> selectAddress(String addressId) async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.setDefaultAddress(
        _currentUserId!,
        addressId,
      );
      
      result.fold(
        (failure) {
          AppLogger.logError('Failed to select address', error: failure.message);
          emit(DeliveryAddressError(failure.message));
          loadAllAddresses();
        },
        (_) {
          AppLogger.logInfo('Address selected: $addressId');
          // State will be updated via stream
        },
      );
    } catch (e) {
      AppLogger.logError('Error selecting address', error: e);
      emit(DeliveryAddressError('Failed to select address'));
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (_currentUserId == null) {
      emit(DeliveryAddressError('User not authenticated'));
      return;
    }

    try {
      emit(DeliveryAddressLoading());
      
      final result = await repository.deleteDeliveryAddress(
        _currentUserId!,
        addressId,
      );
      
      result.fold(
        (failure) {
          AppLogger.logError('Failed to delete address', error: failure.message);
          emit(DeliveryAddressError(failure.message));
          loadAllAddresses();
        },
        (_) {
          AppLogger.logInfo('Address deleted: $addressId');
          // State will be updated via stream
        },
      );
    } catch (e) {
      AppLogger.logError('Error deleting address', error: e);
      emit(DeliveryAddressError('Failed to delete address'));
    }
  }

  @override
  Future<void> close() {
    _addressStreamSubscription?.cancel();
    _addressesListStreamSubscription?.cancel();
    return super.close();
  }
}
