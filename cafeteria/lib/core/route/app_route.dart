import 'package:cafeteria/core/route/route_name.dart';
import 'package:cafeteria/features/home/presentation/pages/category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/di/injaction.dart';
import '../../features/auth/presentation/manager/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/favourite/presentation/manager/favourite_bloc.dart';
import '../../features/home/presentation/manager/home_bloc.dart';
import '../../features/cart/presentation/manager/cart_bloc.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/layout/bottom_navegation_bar.dart';
import '../../features/order/presentation/manager/order_bloc.dart';
import '../../features/order/presentation/pages/checkout_page.dart';
import '../../features/splash/loading_page.dart';
import '../../features/admin/presentation/manager/admin_bloc.dart';
import '../../features/admin/presentation/pages/cafeteria_panel_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.Splash:
        return _buildRoute(const LoadingPage(), settings);

      case RouteNames.roleSelection:
        return _buildRoute(const RoleSelectionPage(), settings);

      case RouteNames.signUp:
      // Wrap SignupPage with its BLoC so it is always fresh
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const SignupPage(),
          ),
          settings,
        );
      case RouteNames.layout:
        final args = settings.arguments as Map<String, String>? ?? {};
        return MaterialPageRoute(
          builder: (_) => CBottomNavigationBar(
            role: args['role'] ?? 'user',
            userName: args['userName'] ?? 'User',
            userId: args['userId'] ?? '',
          ),
        );

      case RouteNames.home:
          final args = settings.arguments as Map<String, String>? ?? {};
  return MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: sl<HomeBloc>(),
      child: HomePage(
        userName: args['userName'] ?? 'User',
        userId: args['userId'] ?? '',
      ),
    ),
  );
      case RouteNames.category:
        return _buildRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<FavouriteBloc>()),
              BlocProvider.value(value: sl<CartBloc>()),
            ],
            child: const CategoryPage(),
          ),
          settings,
        );

      case RouteNames.checkout:
        return _buildRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<OrderBloc>()),
              BlocProvider.value(value: sl<CartBloc>()),
            ],
            child: const CheckoutPage(),
          ),
          settings,
        );

      case RouteNames.layout:
        return _buildRoute(
          const CBottomNavigationBar(role: 'user', userName: '', userId: ''),
          settings,
        );

      case RouteNames.cafeteriaPanel:
        return _buildRoute(
          BlocProvider.value(
            value: sl<AdminBloc>(),
            child: const CafeteriaPanelPage(),
          ),
          settings,
        );

      case RouteNames.signIn:
      return _buildRoute(BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const SignInPage(),
      ), settings);;

      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);;
        ;

      case RouteNames.resetPassword:
        return _buildRoute(const ResetPasswordPage(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
