class PendingUserEntity {
  final String userId;
  final String username;
  final double pendingAmount;
  final int unpaidOrders;

  const PendingUserEntity({
    required this.userId,
    required this.username,
    required this.pendingAmount,
    required this.unpaidOrders,
  });
}

class PendingUsersResult {
  final double totalPending;
  final int userCount;
  final List<PendingUserEntity> users;

  const PendingUsersResult({
    required this.totalPending,
    required this.userCount,
    required this.users,
  });
}
