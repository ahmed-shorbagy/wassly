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

  /// Set the current delivery address for a user
  Future<Either<Failure, void>> setCurrentDeliveryAddress(
    String userId,
    String address,
    String? addressLabel,
  );

  /// Clear the current delivery address
  Future<Either<Failure, void>> clearCurrentDeliveryAddress(String userId);
}

