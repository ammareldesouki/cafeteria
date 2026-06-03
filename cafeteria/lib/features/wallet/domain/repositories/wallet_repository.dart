import '../entities/wallet_transaction_entity.dart';

abstract class WalletRepository {
  Future<WalletDetailsEntity> getWalletDetails({int page = 1, int limit = 20});
}
