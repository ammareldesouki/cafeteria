import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';

import 'core/route/app_route.dart';
import 'core/theme/theme.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnTheWay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RouteNames.Splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
