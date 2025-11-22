import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/delivery_address_repository.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

part 'delivery_address_state.dart';

/// Cubit to manage user's selected delivery address
/// Syncs with Firebase Firestore for persistence across devices
class DeliveryAddressCubit extends Cubit<DeliveryAddressState> {
  final DeliveryAddressRepository repository;
  final AuthCubit authCubit;
  
  String? _currentUserId;
  StreamSubscription? _addressStreamSubscription;

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
        _subscribeToAddressStream();
      } else {
        _currentUserId = null;
        _addressStreamSubscription?.cancel();
        emit(DeliveryAddressNotSet());
      }
    });

    // Check current auth state
    final currentAuthState = authCubit.state;
    if (currentAuthState is AuthAuthenticated) {
      _currentUserId = currentAuthState.user.id;
      _loadAddressFromFirebase();
      _subscribeToAddressStream();
    } else {
      emit(DeliveryAddressNotSet());
    }
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
              address: address.address,
              addressLabel: address.addressLabel,
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
            address: address.address,
            addressLabel: address.addressLabel,
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

  @override
  Future<void> close() {
    _addressStreamSubscription?.cancel();
    return super.close();
  }
}
