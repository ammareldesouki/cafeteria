import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favourite_entity.dart';
import '../../domain/use_cases/add_favourite_usecase.dart';
import '../../domain/use_cases/get_favourites_usecase.dart';
import '../../domain/use_cases/remove_favourite_usecase.dart';




import 'favourite_event.dart';
import 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final GetFavouritesUseCase getFavouritesUseCase;
  final AddFavouriteUseCase addFavouriteUseCase;
  final RemoveFavouriteUseCase removeFavouriteUseCase;

  List<FavouriteEntity> _favourites = [];

  FavouriteBloc({
    required this.getFavouritesUseCase,
    required this.addFavouriteUseCase,
    required this.removeFavouriteUseCase,
  }) : super(FavouriteInitial()) {

    /// GET
    on<GetFavouritesEvent>((event, emit) async {
      emit(FavouriteLoading());
      try {
        _favourites = await getFavouritesUseCase();
        emit(FavouriteLoaded(_favourites));
      } catch (e) {
        emit(FavouriteError(e.toString()));
      }
    });

    /// ADD
    on<AddFavouriteEvent>((event, emit) async {
      emit(FavouriteActionLoading(_favourites, event.itemId));
      try {
        await addFavouriteUseCase(
          event.itemId,
          variantName: event.variantName,
          sugar: event.sugar,
          note: event.note,
        );
        add(GetFavouritesEvent());
      } catch (e) {
        emit(FavouriteError(e.toString()));
      }
    });

    /// REMOVE
    on<RemoveFavouriteEvent>((event, emit) async {
      emit(FavouriteActionLoading(_favourites, event.itemId));
      try {
        await removeFavouriteUseCase(event.itemId);
        _favourites =
            _favourites.where((f) => f.itemId != event.itemId).toList();
        emit(FavouriteLoaded(_favourites));
      } catch (e) {
        emit(FavouriteError(e.toString()));
      }
    });
  }

  bool isFavourite(String itemId) {
    return _favourites.any((f) => f.itemId == itemId);
  }
}