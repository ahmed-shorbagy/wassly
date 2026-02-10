import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, List<WalletTransaction>>> getTransactions(
    String driverId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('wallet_transactions')
          .where('driverId', isEqualTo: driverId)
          .orderBy('date', descending: true)
          .limit(20) // Pagination can be added later
          .get();

      final transactions = snapshot.docs
          .map((doc) => WalletTransactionModel.fromFirestore(doc))
          .toList();

      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(
    WalletTransaction transaction,
  ) async {
    try {
      // 1. Add transaction record
      final transactionModel = WalletTransactionModel(
        id: transaction.id,
        driverId: transaction.driverId,
        amount: transaction.amount,
        type: transaction.type,
        description: transaction.description,
        date: transaction.date,
        orderId: transaction.orderId,
      );

      await _firestore
          .collection('wallet_transactions')
          .doc(transaction.id)
          .set(transactionModel.toFirestore());

      // 2. Update driver's wallet balance and stats
      final driverRef = _firestore
          .collection('drivers')
          .doc(transaction.driverId);

      await _firestore.runTransaction((transactionParams) async {
        final driverDoc = await transactionParams.get(driverRef);
        if (!driverDoc.exists) {
          throw Exception("Driver not found");
        }

        final data = driverDoc.data() as Map<String, dynamic>;
        double currentBalance =
            (data['walletBalance'] as num?)?.toDouble() ?? 0.0;
        double totalEarnings =
            (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
        double cashCollected =
            (data['cashCollected'] as num?)?.toDouble() ?? 0.0;

        // Update fields based on transaction type
        if (transaction.type == TransactionType.credit) {
          currentBalance += transaction.amount;
          // Assuming credit is usually earnings
          if (transaction.description.contains('Earnings') ||
              transaction.description.contains('Delivery')) {
            totalEarnings += transaction.amount;
          }
        } else {
          currentBalance -= transaction.amount;
          // Assuming debit could be cash collection adjustment
          if (transaction.description.contains('Cash collected')) {
            cashCollected += transaction.amount;
          }
        }

        transactionParams.update(driverRef, {
          'walletBalance': currentBalance,
          'totalEarnings': totalEarnings,
          'cashCollected': cashCollected,
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
