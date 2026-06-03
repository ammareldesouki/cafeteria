import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../manager/home_bloc.dart';

class HomeSearchBar extends StatefulWidget {
  final void Function(MenuItemEntity)? onItemTap;
  const HomeSearchBar({super.key, this.onItemTap});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    final hasFocus = _focus.hasFocus;
    if (_hasFocus != hasFocus) {
      setState(() => _hasFocus = hasFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_handleFocusChange);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
          current is HomeLoaded ||
              current is HomeLoading ||
              current is HomeInitial,
          builder: (context, state) {
            final isSearching = state is HomeLoaded && state.isSearching;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hasFocus
                      ? const Color(0xFF3B1A08)
                      : const Color(0xFFE8E0D8),
                  width: 1.5,
                ),
                boxShadow: _hasFocus
                    ? [
                  BoxShadow(
                    color: const Color(0xFF3B1A08).withOpacity(0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                onChanged: (v) {
                  context.read<HomeBloc>().add(SearchQueryChanged(v));
                },
                decoration: InputDecoration(
                  hintText:  AppLocalizations.of(context)!.searchPlaceholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDB0A6),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9E8E82),
                    size: 22,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF9E8E82),
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      _focus.unfocus();
                      context
                          .read<HomeBloc>()
                          .add(const ClearSearchEvent());
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
              ),
            );
          },
        ),

        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) => current is HomeLoaded,
          builder: (context, state) {
            final isSearching = state is HomeLoaded && state.isSearching;
            final results =
            state is HomeLoaded ? state.searchResults : <MenuItemEntity>[];

            if (!isSearching) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 230),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: results.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(
                          color: Color(0xFF9E8E82),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                      : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                    ),
                    itemBuilder: (_, i) => _ResultTile(
                      item: results[i],
                      onTap: () {
                        _focus.unfocus();
                        widget.onItemTap?.call(results[i]);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final MenuItemEntity item;
  final VoidCallback onTap;

  const _ResultTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          item.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: Color(0xFF3B1A08),
              size: 22,
            ),
          ),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        item.description,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9E8E82),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${item.price.toStringAsFixed(0)} L.E',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF3B1A08),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1A08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.category[0].toUpperCase() +
                  item.category.substring(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}