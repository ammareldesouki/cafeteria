import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../auth/di/injaction.dart';
import '../cart/presentation/manager/cart_bloc.dart';
import '../cart/presentation/manager/cart_event.dart';
import '../cart/presentation/pages/cart_page.dart';
import '../favourite/presentation/manager/favourite_bloc.dart';
import '../favourite/presentation/manager/favourite_event.dart';
import '../favourite/presentation/pages/favorite_screen.dart';
import '../home/presentation/manager/home_bloc.dart';
import '../home/presentation/pages/home_page.dart';
import '../order/presentation/manager/order_bloc.dart';
import '../order/presentation/manager/order_event.dart';
import '../order/presentation/pages/order_page.dart';
import '../../core/route/route_name.dart';
import '../auth/presentation/manager/auth_bloc.dart';
import '../auth/domain/entities/user_entity.dart';
import 'widgets/profile_header.dart';
import 'widgets/account_menu_dialog.dart';

class CBottomNavigationBar extends StatefulWidget {
  final String role;
  final String userName;
  final String userId;

  const CBottomNavigationBar({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<CBottomNavigationBar> createState() => _CBottomNavigationBarState();
}

class _CBottomNavigationBarState extends State<CBottomNavigationBar> {
  int _index = 0;

  /// Public method to switch tab programmatically (e.g., from success page)
  void switchToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserLayout();
  }

  Widget _buildUserLayout() {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: sl<HomeBloc>()..add(const FetchMenuEvent()),
        ),
        BlocProvider.value(
          value: sl<FavouriteBloc>()..add(GetFavouritesEvent()),
        ),
        BlocProvider.value(
          value: sl<CartBloc>()..add(GetCartEvent()),
        ),
        BlocProvider.value(
          value: sl<OrderBloc>()..add(GetOrdersEvent()),
        ),
        BlocProvider.value(
          value: sl<AuthBloc>()..add(const GetUserInfoEvent()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserSignedOut) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              RouteNames.signIn,
              (route) => false,
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _index,
                children: [
                  HomePage(
                    userName: widget.userName,
                    userId: widget.userId,
                  ),
                  const FavPage(),
                  const CartPage(),
                  const OrderPage(),
                ],
              ),
              // ── Top Header ──
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String name = widget.userName;
                    UserEntity? user;
                    if (state is UserProfileLoaded) {
                      name = state.user.name;
                      user = state.user;
                    }
                    return ProfileHeader(
                      userName: name,
                      onTap: () {
                        if (user != null) {
                          showDialog(
                            context: context,
                            builder: (context) => AccountMenuDialog(user: user!),
                          );
                        } else {
                          // Fallback if not loaded yet
                          context.read<AuthBloc>().add(const GetUserInfoEvent());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: _navBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
          ],
        ),
      ),
    ));
  }

  Widget _navBar({required List<BottomNavigationBarItem> items}) {
    return Container(
      decoration: BoxDecoration(

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),

        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: items,
      ),
    );
  }
}