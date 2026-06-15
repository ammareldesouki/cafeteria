import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/keys/app_keys.dart';
import 'core/local/locale_bloc.dart';
import 'core/route/app_route.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_bloc.dart';
import 'features/auth/di/injaction.dart';
import 'features/auth/presentation/manager/auth_bloc.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()),
        BlocProvider(create: (_) => sl<LocaleBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleBloc, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                key: ValueKey('app_${locale.languageCode}_${themeMode.name}'),
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                title: "OnTheWay",
                // Theme
                themeMode: themeMode,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,

                // Localization
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) {
                  return Directionality(
                    textDirection: locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  );
                },

                // your existing MaterialApp props stay here
                initialRoute: RouteNames.Splash,
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}