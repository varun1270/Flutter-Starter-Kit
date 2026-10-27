import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_settings.dart';

final themeControllerProvider =
    AsyncNotifierProvider<ThemeController, ThemeSettings>(ThemeController.new);

class ThemeController extends AsyncNotifier<ThemeSettings> {
  static const _designThemeKey = 'design_theme';
  static const _colorSchemeKey = 'color_scheme';
  static const _appearanceKey = 'appearance_mode';
  static const _reduceMotionKey = 'reduce_motion';

  @override
  Future<ThemeSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    return ThemeSettings(
      designTheme: _designThemeFrom(preferences.getString(_designThemeKey)),
      colorScheme: _colorSchemeFrom(preferences.getString(_colorSchemeKey)),
      appearance: _appearanceFrom(preferences.getString(_appearanceKey)),
      reduceMotion: preferences.getBool(_reduceMotionKey) ?? false,
    );
  }

  Future<void> setDesignTheme(AppDesignTheme value) async {
    await _save(
      (state.value ?? const ThemeSettings()).copyWith(designTheme: value),
    );
  }

  Future<void> setColorScheme(AppColorScheme value) async {
    await _save(
      (state.value ?? const ThemeSettings()).copyWith(colorScheme: value),
    );
  }

  Future<void> setAppearance(AppAppearanceMode value) async {
    await _save(
      (state.value ?? const ThemeSettings()).copyWith(appearance: value),
    );
  }

  Future<void> setReduceMotion(bool value) async {
    await _save(
      (state.value ?? const ThemeSettings()).copyWith(reduceMotion: value),
    );
  }

  Future<void> _save(ThemeSettings settings) async {
    state = AsyncData(settings);
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_designThemeKey, settings.designTheme.name),
      preferences.setString(_colorSchemeKey, settings.colorScheme.name),
      preferences.setString(_appearanceKey, settings.appearance.name),
      preferences.setBool(_reduceMotionKey, settings.reduceMotion),
    ]);
  }

  AppDesignTheme _designThemeFrom(String? value) =>
      AppDesignTheme.values.firstWhere(
        (theme) => theme.name == value,
        orElse: () => AppDesignTheme.modernMinimal,
      );

  AppColorScheme _colorSchemeFrom(String? value) {
    // Purple was the starter-kit default before the visual refresh. Treat an
    // old saved value as the new editorial accent so existing installs also
    // receive the updated login experience.
    if (value == AppColorScheme.purple.name ||
        value == AppColorScheme.orange.name) {
      return AppColorScheme.champagne;
    }
    return AppColorScheme.values.firstWhere(
      (scheme) => scheme.name == value,
      orElse: () => AppColorScheme.champagne,
    );
  }

  AppAppearanceMode _appearanceFrom(String? value) =>
      AppAppearanceMode.values.firstWhere(
        (mode) => mode.name == value,
        orElse: () => AppAppearanceMode.system,
      );
}
