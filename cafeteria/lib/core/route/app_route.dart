import 'package:cafeteria/core/route/route_name.dart';
import 'package:cafeteria/features/home/presentation/pages/catefory_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/di/injaction.dart';
import '../../features/auth/presentation/manager/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/manager/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/layout/bottom_navegation_bar.dart';
import '../../features/splash/loading_page.dart';


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
        return _buildRoute(const CategoryPage(), settings);
        case RouteNames.layout
        :return _buildRoute(const CBottomNavigationBar( role: 'user', userName: '', userId: '',), settings);



    case RouteNames.signIn:
      return _buildRoute(BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const SignInPage(),
      ), settings);

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
