import 'package:equatable/equatable.dart';

enum TransactionType {
  credit, // Money added to wallet (e.g., earnings)
  debit, // Money deducted from wallet (e.g., payouts, cash collection adjustments)
}

class WalletTransaction extends Equatable {
  final String id;
  final String driverId;
  final double amount;
  final TransactionType type;
  final String description;
  final DateTime date;
  final String? orderId;

  const WalletTransaction({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.orderId,
  });

  @override
  List<Object?> get props => [
    id,
    driverId,
    amount,
    type,
    description,
    date,
    orderId,
  ];
}
