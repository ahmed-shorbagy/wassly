import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wallet_transaction.dart';

abstract class WalletRepository {
  /// Get all transactions for a driver
  Future<Either<Failure, List<WalletTransaction>>> getTransactions(
    String driverId,
  );

  /// Add a new transaction
  Future<Either<Failure, void>> addTransaction(WalletTransaction transaction);
}
