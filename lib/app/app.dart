import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'theme/theme_settings.dart';

class StarterKitApp extends ConsumerWidget {
  const StarterKitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings =
        ref.watch(themeControllerProvider).value ?? const ThemeSettings();
    final themeMode = switch (settings.appearance) {
      AppAppearanceMode.system => ThemeMode.system,
      AppAppearanceMode.light => ThemeMode.light,
      AppAppearanceMode.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'Northstar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(
        designTheme: settings.designTheme,
        colorScheme: settings.colorScheme,
        reduceMotion: settings.reduceMotion,
      ),
      darkTheme: AppTheme.dark(
        designTheme: settings.designTheme,
        colorScheme: settings.colorScheme,
        reduceMotion: settings.reduceMotion,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
