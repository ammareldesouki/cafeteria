abstract class WalletEvent {
  const WalletEvent();
}

class FetchWalletDetailsEvent extends WalletEvent {
  final int page;
  final int limit;

  const FetchWalletDetailsEvent({this.page = 1, this.limit = 20});
}
