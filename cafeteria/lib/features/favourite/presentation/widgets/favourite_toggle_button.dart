import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/favourite_bloc.dart';
import '../manager/favourite_event.dart';
import '../manager/favourite_state.dart';


class FavouriteToggleButton extends StatelessWidget {
  final String itemId;

  const FavouriteToggleButton({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouriteBloc, FavouriteState>(
      builder: (context, state) {
        final bloc = context.read<FavouriteBloc>();
        final isFav = bloc.isFavourite(itemId);
        final isLoading =
            state is FavouriteActionLoading && state.itemId == itemId;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
            if (isFav) {
              bloc.add(RemoveFavouriteEvent(itemId));
            } else {
              bloc.add(AddFavouriteEvent(itemId));
            }
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : Icon(
            isFav
                ? Icons.favorite
                : Icons.favorite_border,
          ),
        );
      },
    );
  }
}