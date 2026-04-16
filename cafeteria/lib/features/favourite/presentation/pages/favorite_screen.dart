import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../manager/favourite_bloc.dart';
import '../manager/favourite_event.dart';
import '../manager/favourite_state.dart';
import '../widgets/favourite_item_card.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavouriteBloc>().add(GetFavouritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (context, state) {
            if (state is FavouriteLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B1A08)),
              );
            }

            if (state is FavouriteError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => context
                    .read<FavouriteBloc>()
                    .add(GetFavouritesEvent()),
              );
            }

            final favourites =
            state is FavouriteLoaded ? state.favourites : [];

            if (favourites.isEmpty) {
              return _EmptyState(
                onRefresh: () => context
                    .read<FavouriteBloc>()
                    .add(GetFavouritesEvent()),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF3B1A08),
              onRefresh: () async {
                context.read<FavouriteBloc>().add(GetFavouritesEvent());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  return FavouriteItemCard(item: favourites[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Box icon circle — matches screenshot
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E8DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 48,
              color: Color(0xFF9E7E65),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            AppLocalizations.of(context)!.favouriteEmpty,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B1A08),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            AppLocalizations.of(context)!.favouriteEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
            ),
          ),

          const SizedBox(height: 28),

          // Refresh button
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1A08),orderRadius: BorderRadius.circular(14),
              ),
              cchild: Row(
                mainAxisSize: MainAxisSize.min,hildren: [
                  IIcon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.refresh,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Color(0xFF8B7355), size: 52),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF8B7355)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1A08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                AppLocalizations.of(context)!.tryAgain,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}