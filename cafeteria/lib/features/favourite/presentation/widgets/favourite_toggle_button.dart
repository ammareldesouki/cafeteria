import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/cubit/favourite_cubit.dart';
import '../../presentation/cubit/favourite_state.dart';

/// Drop this widget anywhere you show a product card.
/// It reads from FavouriteCubit and toggles on tap.
class FavouriteToggleButton extends StatelessWidget {
  final String itemId;

  const FavouriteToggleButton({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouriteCubit, FavouriteState>(
      builder: (context, state) {
        final cubit = context.read<FavouriteCubit>();
        final isFav = cubit.isFavourite(itemId);
        final isLoading =
            state is FavouriteActionLoading && state.itemId == itemId;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  if (isFav) {
                    cubit.removeFavourite(itemId);
                  } else {
                    cubit.addFavourite(itemId);
                  }
                },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF3B1A08),
                    ),
                  )
                : Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isFav),
                    color: isFav
                        ? const Color(0xFFE57373)
                        : const Color(0xFF8B7355),
                    size: 26,
                  ),
          ),
        );
      },
    );
  }
}
