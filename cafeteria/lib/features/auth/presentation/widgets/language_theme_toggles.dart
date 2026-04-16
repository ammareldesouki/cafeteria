import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local/locale_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';

class LanguageThemeToggles extends StatelessWidget {
  const LanguageThemeToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state;
    final themeMode = context.watch<ThemeBloc>().state;
    final isArabic = locale.languageCode == 'ar';
    final isDark = themeMode == ThemeMode.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language Toggle
        IconButton(
          onPressed: () => context.read<LocaleBloc>().add(ToggleLocaleEvent()),
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isArabic ? 'EN' : 'AR',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        
        // Theme Toggle
        IconButton(
          onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.amber : Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
