import '../../domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.orderId,
    required super.amount,
    required super.type,
    required super.description,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: _str(json['_id']),
      orderId: json['orderId'] == null ? null : _str(json['orderId']),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      type: _str(json['type']),
      description: _str(json['description']),
      createdAt: _date(json['createdAt']),
    );
  }

  static String _str(dynamic v) => v == null ? '' : v.toString();

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class WalletDetailsModel extends WalletDetailsEntity {
  const WalletDetailsModel({
    required super.balance,
    required super.updatedAt,
    required super.transactions,
    required super.totalCount,
    required super.page,
    required super.totalPages,
  });

  factory WalletDetailsModel.fromJson(Map<String, dynamic> json) {
    final tx = (json['transactions'] as Map<String, dynamic>?) ?? {};
    final List<dynamic> data = (tx['data'] as List<dynamic>?) ?? [];

    return WalletDetailsModel(
      balance: (json['balance'] as num? ?? 0).toDouble(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'].toString()),
      transactions: data
          .map((e) =>
              WalletTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (tx['totalCount'] as num? ?? 0).toInt(),
      page: (tx['page'] as num? ?? 1).toInt(),
      totalPages: (tx['totalPages'] as num? ?? 1).toInt(),
    );
  }
}
