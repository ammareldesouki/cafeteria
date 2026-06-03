import '../../domain/entities/wallet_transaction_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../data_sources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<WalletDetailsEntity> getWalletDetails({
    int page = 1,
    int limit = 20,
  }) {
    return remoteDataSource.getWalletDetails(page: page, limit: limit);
  }
}
