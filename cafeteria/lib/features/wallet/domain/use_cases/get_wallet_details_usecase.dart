import '../entities/wallet_transaction_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletDetailsUseCase {
  final WalletRepository repository;

  GetWalletDetailsUseCase(this.repository);

  Future<WalletDetailsEntity> call({int page = 1, int limit = 20}) {
    return repository.getWalletDetails(page: page, limit: limit);
  }
}
