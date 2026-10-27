# Design System

The app uses Material 3 through `AppTheme.light/dark`. `ThemeSettings` supports four design themes (`modernMinimal`, `material3`, `elegant`, `bold`), six palettes (`blue`, `purple`, `green`, `orange`, `monochrome`, `champagne`), system/light/dark appearance, and persisted reduced motion.

## Tokens and reuse

Use `Theme.of(context).colorScheme` and `textTheme` first. Shared rhythm lives in `AppSpacing` (4, 8, 12, 16, 24, 32, 48), `AppRadii`, `AppShadows`, and `AppMotion`. `ThemeTokens.forTheme` changes radii, elevations, borders, padding, font family, heading weight, and tracking per design theme. Reuse `AppCard`, `AppButton`, `AppTextField`, `AppLoadingButton`, `AppAsyncState`, and the loading primitives before creating a local equivalent.

Never use `Colors.*` or fixed brand colors in feature UI except where a deliberate asset/brand surface is documented; use semantic roles such as `primary`, `onSurface`, `surfaceContainer`, `outline`, and `error`. Do not hardcode a single theme's radius, font, button height, or spacing in a reusable component. The current splash screen has deliberate dark branding; preserve it unless the task explicitly changes branding.

Use `SafeArea`, scrollable content, `LayoutBuilder`, and the existing max-width/padding approach for responsive layouts. Give interactive icons tooltips, keep tap targets usable, provide labels and meaningful semantics, and ensure contrast in both brightness modes. Validate every configured theme when a reusable screen/component changes.

Assets currently present are `assets/icons/northstar.svg` and `assets/animations/northstar_pulse.json`; `assets/images/` is declared but absent. Add assets only with a corresponding pubspec declaration and verified fallback behavior.
