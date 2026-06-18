import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../l10n/app_localizations.dart';
import '../admin/presentation/manager/admin_bloc.dart';
import '../admin/presentation/manager/admin_event.dart';
import '../admin/presentation/pages/cafeteria_panel_page.dart';
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
import '../../core/services/fcm_service.dart';
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
  State<CBottomNavigationBar> createState() => CBottomNavigationBarState();
}

class CBottomNavigationBarState extends State<CBottomNavigationBar> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetUserInfoEvent());
    // Register this device so the customer receives order-tracking pushes.
    FcmService.instance.registerToken();
  }

  /// Public method to switch tab programmatically (e.g., from success page)
  void switchToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'admin') {
      return _buildAdminLayout();
    } else {
      return _buildUserLayout();
    }
  }

  Widget _buildUserLayout() {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: sl<HomeBloc>()
              ..add(const FetchMenuEvent()),
          ),
          BlocProvider.value(
            value: sl<FavouriteBloc>()
              ..add(GetFavouritesEvent()),
          ),
          BlocProvider.value(
            value: sl<CartBloc>()
              ..add(GetCartEvent()),
          ),
          BlocProvider.value(
            value: sl<OrderBloc>()
              ..add(GetOrdersEvent()),
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
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
                            builder: (context) =>
                                AccountMenuDialog(user: user!),
                          );
                        } else {
                          // Fallback if not loaded yet
                          context.read<AuthBloc>().add(
                              const GetUserInfoEvent());
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            body: IndexedStack(
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
            bottomNavigationBar: _navBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: AppLocalizations.of(context)!.favorites,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart_rounded),
                  label: AppLocalizations.of(context)!.cart,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: AppLocalizations.of(context)!.order,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildAdminLayout() {
    return BlocProvider(
      create: (context) =>
      sl<AdminBloc>()
        ..add(LoadDashboardDataEvent()),
      child: const CafeteriaPanelPage(),
    );
  }

  Widget _navBar({required List<BottomNavigationBarItem> items}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        selectedItemColor: isDark ? const Color(0xFFD7BFAE) : Colors.brown,
        unselectedItemColor: isDark ? Colors.white60 : Colors.black,
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