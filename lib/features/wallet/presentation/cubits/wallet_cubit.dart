import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../../domain/repositories/wallet_repository.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<WalletTransaction> transactions;

  const WalletLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(WalletInitial());

  Future<void> getTransactions(String driverId) async {
    emit(WalletLoading());
    final result = await _repository.getTransactions(driverId);
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (transactions) => emit(WalletLoaded(transactions)),
    );
  }
}
