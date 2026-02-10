import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.driverId,
    required super.amount,
    required super.type,
    required super.description,
    required super.date,
    super.orderId,
  });

  factory WalletTransactionModel.fromEntity(WalletTransaction entity) {
    return WalletTransactionModel(
      id: entity.id,
      driverId: entity.driverId,
      amount: entity.amount,
      type: entity.type,
      description: entity.description,
      date: entity.date,
      orderId: entity.orderId,
    );
  }

  factory WalletTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletTransactionModel(
      id: doc.id,
      driverId: data['driverId'] as String,
      amount: (data['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == (data['type'] as String),
        orElse: () => TransactionType.credit,
      ),
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      orderId: data['orderId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'description': description,
      'date': Timestamp.fromDate(date),
      'orderId': orderId,
    };
  }
}
