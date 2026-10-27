import 'package:flutter/material.dart';

import 'theme_settings.dart';

/// Shared layout rhythm used by screens and reusable widgets.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x12000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

abstract final class AppMotion {
  static const quick = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);
}

@immutable
class MotionTheme extends ThemeExtension<MotionTheme> {
  const MotionTheme({required this.reduceMotion});

  final bool reduceMotion;

  Duration get quickDuration => reduceMotion ? Duration.zero : AppMotion.quick;
  Duration get standardDuration =>
      reduceMotion ? Duration.zero : AppMotion.standard;

  @override
  MotionTheme copyWith({bool? reduceMotion}) {
    return MotionTheme(reduceMotion: reduceMotion ?? this.reduceMotion);
  }

  @override
  MotionTheme lerp(covariant MotionTheme? other, double t) {
    return MotionTheme(
      reduceMotion: t < 0.5
          ? reduceMotion
          : other?.reduceMotion ?? reduceMotion,
    );
  }
}

class ThemeTokens {
  const ThemeTokens({
    required this.cardRadius,
    required this.controlRadius,
    required this.buttonRadius,
    required this.cardElevation,
    required this.buttonElevation,
    required this.borderWidth,
    required this.contentPadding,
    required this.fontFamily,
    required this.headingWeight,
    required this.headingLetterSpacing,
  });

  final double cardRadius;
  final double controlRadius;
  final double buttonRadius;
  final double cardElevation;
  final double buttonElevation;
  final double borderWidth;
  final EdgeInsets contentPadding;
  final String? fontFamily;
  final FontWeight headingWeight;
  final double headingLetterSpacing;

  factory ThemeTokens.forTheme(AppDesignTheme theme) => switch (theme) {
    AppDesignTheme.modernMinimal => const ThemeTokens(
      cardRadius: AppRadii.xl,
      controlRadius: AppRadii.lg,
      buttonRadius: AppRadii.lg,
      cardElevation: 0,
      buttonElevation: 0,
      borderWidth: 1,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fontFamily: null,
      headingWeight: FontWeight.w800,
      headingLetterSpacing: -1.2,
    ),
    AppDesignTheme.material3 => const ThemeTokens(
      cardRadius: AppRadii.lg,
      controlRadius: AppRadii.lg,
      buttonRadius: AppRadii.pill,
      cardElevation: 1,
      buttonElevation: 1,
      borderWidth: 0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fontFamily: null,
      headingWeight: FontWeight.w700,
      headingLetterSpacing: -0.6,
    ),
    AppDesignTheme.elegant => const ThemeTokens(
      cardRadius: AppRadii.md,
      controlRadius: AppRadii.md,
      buttonRadius: AppRadii.md,
      cardElevation: 0,
      buttonElevation: 0,
      borderWidth: 1,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      fontFamily: 'Georgia',
      headingWeight: FontWeight.w600,
      headingLetterSpacing: -0.3,
    ),
    AppDesignTheme.bold => const ThemeTokens(
      cardRadius: AppRadii.sm,
      controlRadius: AppRadii.sm,
      buttonRadius: AppRadii.sm,
      cardElevation: 4,
      buttonElevation: 2,
      borderWidth: 2,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fontFamily: null,
      headingWeight: FontWeight.w900,
      headingLetterSpacing: -1.4,
    ),
  };
}

abstract final class AppTheme {
  static ThemeData light({
    required AppDesignTheme designTheme,
    required AppColorScheme colorScheme,
    bool reduceMotion = false,
  }) {
    return _buildTheme(
      brightness: Brightness.light,
      designTheme: designTheme,
      colorScheme: colorScheme,
      reduceMotion: reduceMotion,
    );
  }

  static ThemeData dark({
    required AppDesignTheme designTheme,
    required AppColorScheme colorScheme,
    bool reduceMotion = false,
  }) {
    return _buildTheme(
      brightness: Brightness.dark,
      designTheme: designTheme,
      colorScheme: colorScheme,
      reduceMotion: reduceMotion,
    );
  }

  static Color paletteColor(AppColorScheme palette) => switch (palette) {
    AppColorScheme.blue => const Color(0xFF2563EB),
    AppColorScheme.purple => const Color(0xFF7C3AED),
    AppColorScheme.green => const Color(0xFF059669),
    AppColorScheme.orange => const Color(0xFFE76F51),
    AppColorScheme.monochrome => const Color(0xFF475467),
    AppColorScheme.champagne => const Color(0xFFC6A15B),
  };

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppDesignTheme designTheme,
    required AppColorScheme colorScheme,
    required bool reduceMotion,
  }) {
    final isDark = brightness == Brightness.dark;
    final tokens = ThemeTokens.forTheme(designTheme);
    final primary = paletteColor(colorScheme);
    final onPrimary = colorScheme == AppColorScheme.champagne
        ? const Color(0xFF1A160E)
        : Colors.white;
    final colors =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          contrastLevel: designTheme == AppDesignTheme.bold ? 0.25 : 0,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          surface: isDark ? const Color(0xFF0E0E0D) : const Color(0xFFF6F3EC),
          surfaceContainerLowest: isDark
              ? const Color(0xFF0A0A09)
              : const Color(0xFFFFFCF6),
          surfaceContainer: isDark
              ? const Color(0xFF181815)
              : const Color(0xFFFBF8F1),
          surfaceContainerHighest: isDark
              ? const Color(0xFF29261F)
              : const Color(0xFFEAE3D6),
        );
    final foreground = colors.onSurface;
    final outline = colors.outline.withValues(alpha: isDark ? 0.72 : 0.9);
    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius),
          borderSide: BorderSide(color: color, width: width),
        );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.cardRadius),
      side: tokens.borderWidth == 0
          ? BorderSide.none
          : BorderSide(color: outline, width: tokens.borderWidth),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      fontFamily: tokens.fontFamily,
      pageTransitionsTheme: _pageTransitionsTheme(reduceMotion),
      extensions: [MotionTheme(reduceMotion: reduceMotion)],
    );
    final textTheme = _textTheme(base.textTheme, colors, tokens, isDark);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: designTheme == AppDesignTheme.bold ? 2 : 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: foreground,
        centerTitle: designTheme == AppDesignTheme.elegant,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainer,
        contentPadding: tokens.contentPadding,
        border: inputBorder(outline, tokens.borderWidth),
        enabledBorder: inputBorder(outline, tokens.borderWidth),
        focusedBorder: inputBorder(colors.primary, tokens.borderWidth + 0.5),
        errorBorder: inputBorder(colors.error, tokens.borderWidth),
        focusedErrorBorder: inputBorder(colors.error, tokens.borderWidth + 0.5),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: tokens.cardElevation,
        shadowColor: colors.shadow.withValues(alpha: 0.18),
        margin: EdgeInsets.zero,
        color: colors.surfaceContainer,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
            ),
          ),
          elevation: WidgetStatePropertyAll(tokens.buttonElevation),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.outline, width: tokens.borderWidth),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.buttonRadius),
            ),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: designTheme == AppDesignTheme.bold ? 82 : 76,
        elevation: tokens.cardElevation,
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
        ),
        side: BorderSide(color: outline, width: tokens.borderWidth),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: textTheme.labelLarge,
      ),
      dialogTheme: DialogThemeData(
        elevation: tokens.cardElevation + 4,
        backgroundColor: colors.surfaceContainer,
        shape: cardShape,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainer,
        elevation: tokens.cardElevation + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.cardRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: tokens.buttonElevation + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
      ),
    );
  }

  static PageTransitionsTheme _pageTransitionsTheme(bool reduceMotion) {
    final builder = AppPageTransitionsBuilder(reduceMotion: reduceMotion);
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: builder,
        TargetPlatform.iOS: builder,
        TargetPlatform.macOS: builder,
        TargetPlatform.windows: builder,
        TargetPlatform.linux: builder,
        TargetPlatform.fuchsia: builder,
      },
    );
  }

  static TextTheme _textTheme(
    TextTheme base,
    ColorScheme colors,
    ThemeTokens tokens,
    bool isDark,
  ) {
    final secondary = colors.onSurfaceVariant;
    return base.copyWith(
      displaySmall: TextStyle(
        color: colors.onSurface,
        fontSize: 36,
        fontWeight: tokens.headingWeight,
        height: 1.08,
        letterSpacing: tokens.headingLetterSpacing,
      ),
      headlineSmall: TextStyle(
        color: colors.onSurface,
        fontSize: 26,
        fontWeight: tokens.headingWeight,
        letterSpacing: tokens.headingLetterSpacing / 2,
      ),
      titleLarge: TextStyle(
        color: colors.onSurface,
        fontSize: 20,
        fontWeight: tokens.headingWeight,
        letterSpacing: tokens.headingLetterSpacing / 4,
      ),
      titleMedium: TextStyle(
        color: colors.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: colors.onSurface, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(
        color: isDark ? colors.onSurfaceVariant : secondary,
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: colors.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// A short, interruptible transition that follows the display's native vsync.
/// It yields immediately to OS accessibility settings.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Duration get transitionDuration => AppMotion.standard;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion || MediaQuery.disableAnimationsOf(context)) return child;

    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final position = Tween<Offset>(
      begin: const Offset(0.035, 0),
      end: Offset.zero,
    ).animate(curve);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(position: position, child: child),
    );
  }
}
