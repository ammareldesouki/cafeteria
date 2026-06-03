import 'package:cafeteria/core/network/dio_handler.dart';

import '../models/wallet_models.dart';

abstract class WalletRemoteDataSource {
  Future<WalletDetailsModel> getWalletDetails({int page = 1, int limit = 20});
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final NetworkDioHandler _dioHandler;

  WalletRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<WalletDetailsModel> getWalletDetails({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioHandler.dio.get(
      '/me/wallet/details',
      queryParameters: {'page': page, 'limit': limit},
    );
    return WalletDetailsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
