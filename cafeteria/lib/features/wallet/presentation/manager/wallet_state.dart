import '../../domain/entities/wallet_transaction_entity.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletDetailsEntity details;

  WalletLoaded(this.details);
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
