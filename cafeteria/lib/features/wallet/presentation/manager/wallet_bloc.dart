import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_wallet_details_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletDetailsUseCase getWalletDetailsUseCase;

  WalletBloc({required this.getWalletDetailsUseCase})
      : super(WalletInitial()) {
    on<FetchWalletDetailsEvent>((event, emit) async {
      emit(WalletLoading());
      try {
        final details = await getWalletDetailsUseCase(
          page: event.page,
          limit: event.limit,
        );
        emit(WalletLoaded(details));
      } catch (e) {
        emit(WalletError(e.toString()));
      }
    });
  }
}
