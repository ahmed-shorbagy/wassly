import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/delivery_address_entity.dart';

abstract class DeliveryAddressRepository {
  /// Get the current/default delivery address for a user
  Future<Either<Failure, DeliveryAddressEntity?>> getCurrentDeliveryAddress(
    String userId,
  );

  /// Stream the current delivery address for real-time updates
  Stream<DeliveryAddressEntity?> streamCurrentDeliveryAddress(String userId);

  /// Get all delivery addresses for a user
  Future<Either<Failure, List<DeliveryAddressEntity>>> getAllDeliveryAddresses(
    String userId,
  );

  /// Stream all delivery addresses for real-time updates
  Stream<List<DeliveryAddressEntity>> streamAllDeliveryAddresses(String userId);

  /// Add a new delivery address for a user
  Future<Either<Failure, DeliveryAddressEntity>> addDeliveryAddress(
    String userId,
    DeliveryAddressEntity address,
  );

  /// Update an existing delivery address
  Future<Either<Failure, void>> updateDeliveryAddress(
    String userId,
    DeliveryAddressEntity address,
  );

  /// Set the default delivery address (marks as default and unmarks others)
  Future<Either<Failure, void>> setDefaultAddress(
    String userId,
    String addressId,
  );

  /// Delete a delivery address
  Future<Either<Failure, void>> deleteDeliveryAddress(
    String userId,
    String addressId,
  );

  /// Set the current delivery address for a user (legacy method - creates/updates default)
  Future<Either<Failure, void>> setCurrentDeliveryAddress(
    String userId,
    String address,
    String? addressLabel,
  );

  /// Clear the current delivery address
  Future<Either<Failure, void>> clearCurrentDeliveryAddress(String userId);
}

