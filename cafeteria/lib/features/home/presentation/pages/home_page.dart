import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../manager/home_bloc.dart';
import '../widgets/category_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/welcome_banner.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userId;

  const HomePage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const FetchMenuEvent());
  }

  void _onCategoryTap(
      BuildContext context,
      String category,
      List<MenuItemEntity> products,
      ) {
    Navigator.pushNamed(
      context,
      RouteNames.category,
      arguments: {
        'category': category,
        'products': products,
      },
    );
  }
  void _onItemTap(MenuItemEntity item) {
    Navigator.pushNamed(context, '/item-detail', arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    WelcomeBanner(userName: widget.userName),
                    const SizedBox(height: 20),

                    HomeSearchBar(onItemTap: _onItemTap),
                    const SizedBox(height: 28),

                    if (state is HomeInitial || state is HomeLoading)
                      const HomeSkeleton()
                    else if (state is HomeError)
                      Center(
                        child: _ErrorView(
                          message: state.message,
                          onRetry: () =>
                              context.read<HomeBloc>().add(const FetchMenuEvent()),
                        ),
                      )
                    else if (state is HomeLoaded) ...[
                        if (!state.isSearching) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.categories,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '${state.allItems.length} ${AppLocalizations.of(
                                    context)!.items}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9E8E82),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          CategoryCard(
                            title: AppLocalizations.of(context)!.coldDrinks,
                            subtitle: 'Refreshing iced beverages',
                            onTap: () => _onCategoryTap(
                              context,
                              AppLocalizations.of(context)!.coldDrinks,
                              state.coldDrinks,
                            ),
                            gradientColors: const [
                              Color(0xFFB68F60),
                              Color(0xFFF5F5DC),
                              Color(0xFF3E2522)
                            ],
                            decorIcon: Icons.ac_unit_rounded,
                          ),
                          const SizedBox(height: 14),

                          CategoryCard(
                            title: AppLocalizations.of(context)!.hotDrinks,
                            subtitle: 'Warm comforting beverages',
                            onTap: () => _onCategoryTap(
                              context,
                              AppLocalizations.of(context)!.hotDrinks,
                              state.hotDrinks,
                            ),
                            gradientColors: const [
                              Color(0xFFB68F60),
                              Color(0xFFF5F5DC),
                              Color(0xFF3E2522)
                            ],
                            decorIcon: Icons.local_fire_department_rounded,
                          ),
                          const SizedBox(height: 14),

                          CategoryCard(
                            title: AppLocalizations.of(context)!.sides,
                            subtitle: 'Choose your selection of side items',
                            onTap: () => _onCategoryTap(
                              context,
                              AppLocalizations.of(context)!.sides,
                              state.sideItems,
                            ),
                            gradientColors: const [
                              Color(0xFFB68F60),
                              Color(0xFFF5F5DC),
                              Color(0xFF3E2522)
                            ],
                            decorIcon: Icons.dinner_dining_rounded,
                          ),
                          const SizedBox(height: 28),

                          // _StatsRow(
                          //   coldCount: state.coldDrinks.length,
                          //   hotCount: state.hotDrinks.length,
                          //   sideCount: state.sideItems.length,
                          // ),
                        ],
                      ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//
// class _StatsRow extends StatelessWidget {
//   final int coldCount;
//   final int hotCount;
//   final int sideCount;
//
//   const _StatsRow({
//     required this.coldCount,
//     required this.hotCount,
//     required this.sideCount,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _StatChip(
//           label: 'Cold',
//           count: coldCount,
//           color: const Color(0xFF5B8FD4),
//         ),
//         const SizedBox(width: 10),
//         _StatChip(
//           label: 'Hot',
//           count: hotCount,
//           color: const Color(0xFFD47B3F),
//         ),
//         const SizedBox(width: 10),
//         _StatChip(
//           label: 'Sides',
//           count: sideCount,
//           color: const Color(0xFF8B7355),
//         ),
//       ],
//     );
//   }
// }
//
// class _StatChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//
//   const _StatChip({
//     required this.label,
//     required this.count,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Color(0xFF9E8E82),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF5EDE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 34,
              color: Color(0xFF9E8E82),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9E8E82),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF3B1A08),
            ),
            label: Text(
              AppLocalizations.of(context)!.tryAgain,
              style: TextStyle(color: Color(0xFF3B1A08)),
            ),
          ),
        ],
      ),
    );
  }
}