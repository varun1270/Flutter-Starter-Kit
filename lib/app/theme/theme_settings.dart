// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';

enum AppDesignTheme { modernMinimal, material3, elegant, bold }

enum AppColorScheme { blue, purple, green, orange, monochrome, champagne }

enum AppAppearanceMode { system, light, dark }

class ThemeSettings {
  const ThemeSettings({
    this.designTheme = AppDesignTheme.modernMinimal,
    this.colorScheme = AppColorScheme.champagne,
    this.appearance = AppAppearanceMode.system,
    bool reduceMotion = false,
  }) : _reduceMotion = reduceMotion;

  final AppDesignTheme designTheme;
  final AppColorScheme colorScheme;
  final AppAppearanceMode appearance;
  final bool? _reduceMotion;

  // The nullable backing field keeps hot reloads safe when a new preference
  // is introduced while an older ThemeSettings object is still in memory.
  bool get reduceMotion => _reduceMotion ?? false;

  ThemeSettings copyWith({
    AppDesignTheme? designTheme,
    AppColorScheme? colorScheme,
    AppAppearanceMode? appearance,
    bool? reduceMotion,
  }) {
    return ThemeSettings(
      designTheme: designTheme ?? this.designTheme,
      colorScheme: colorScheme ?? this.colorScheme,
      appearance: appearance ?? this.appearance,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

extension AppDesignThemeLabels on AppDesignTheme {
  String get label => switch (this) {
    AppDesignTheme.modernMinimal => 'Modern Minimal',
    AppDesignTheme.material3 => 'Material 3',
    AppDesignTheme.elegant => 'Elegant',
    AppDesignTheme.bold => 'Bold',
  };

  String get description => switch (this) {
    AppDesignTheme.modernMinimal => 'Quiet surfaces and generous space',
    AppDesignTheme.material3 => 'Familiar, expressive Material components',
    AppDesignTheme.elegant => 'Refined type and subtle outlines',
    AppDesignTheme.bold => 'Confident contrast and strong emphasis',
  };
}

extension AppColorSchemeLabels on AppColorScheme {
  String get label => switch (this) {
    AppColorScheme.blue => 'Blue',
    AppColorScheme.purple => 'Purple',
    AppColorScheme.green => 'Green',
    AppColorScheme.orange => 'Orange',
    AppColorScheme.monochrome => 'Monochrome',
    AppColorScheme.champagne => 'Champagne',
  };
}

extension AppAppearanceModeLabels on AppAppearanceMode {
  String get label => switch (this) {
    AppAppearanceMode.system => 'System',
    AppAppearanceMode.light => 'Light',
    AppAppearanceMode.dark => 'Dark',
  };

  IconData get icon => switch (this) {
    AppAppearanceMode.system => Icons.brightness_auto_outlined,
    AppAppearanceMode.light => Icons.light_mode_outlined,
    AppAppearanceMode.dark => Icons.dark_mode_outlined,
  };
}
