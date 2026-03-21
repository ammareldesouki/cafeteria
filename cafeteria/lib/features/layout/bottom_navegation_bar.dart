import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../auth/di/injaction.dart';
import '../cart/presentation/pages/cart_page.dart';
import '../favourite/presentation/pages/favorite_screen.dart';
import '../home/presentation/manager/home_bloc.dart';
import '../home/presentation/pages/home_page.dart';
import '../order/presentation/pages/order_page.dart';

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

  @override
  Widget build(BuildContext context) {
    // if (widget.role.toLowerCase() == 'admin') {
    //   return const AdminDashboard();
    // }

    return _buildUserLayout();
  }

  Widget _buildUserLayout() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<HomeBloc>()..add(const FetchMenuEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F4F0),
        body: IndexedStack(
          index: _index,
          children: [
            HomePage(
              userName: widget.userName,
              userId: widget.userId,
            ),
            const FavouritePage(),
            const CartPage(),
            const OrderPage(),
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
    );
  }

  Widget _navBar({required List<BottomNavigationBarItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
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