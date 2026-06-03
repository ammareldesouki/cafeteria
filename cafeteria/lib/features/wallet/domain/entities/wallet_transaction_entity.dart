class WalletTransactionEntity {
  final String id;
  final String? orderId;
  final double amount;

  /// 'credit' (debt settled / money in) or 'debit' (delivered unpaid / owed).
  final String type;
  final String description;
  final DateTime? createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type.toLowerCase() == 'credit';
}

class WalletDetailsEntity {
  final double balance;
  final DateTime? updatedAt;
  final List<WalletTransactionEntity> transactions;
  final int totalCount;
  final int page;
  final int totalPages;

  const WalletDetailsEntity({
    required this.balance,
    required this.updatedAt,
    required this.transactions,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });
}
