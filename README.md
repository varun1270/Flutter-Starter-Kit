# Northstar Flutter Starter Kit

Northstar is a reusable Flutter starter kit built on Flutter 3.44+, Dart 3.12+, Material 3, Riverpod, and go_router. It provides a polished foundation for authentication, protected navigation, themes, API integration, and feature-first development.

## Quick start

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Configure an API endpoint without committing environment secrets:

```bash
flutter run --dart-define=API_BASE_URL=https://api.yourapp.com
```

The current auth flow is deliberately backed by `MockAuthRepository`. It demonstrates the complete UI and state flow without pretending to be a real backend. Replace it with an implementation of `AuthRepository` in `lib/features/auth/data/` and keep the controller and screens unchanged.

## Project structure

```text
lib/
├── app/                 # App root, router, and theme system
├── core/                # Constants, errors, network, validation, UI primitives
├── features/
│   ├── auth/            # Auth contract, mock data source, screens, controller
│   ├── home/            # Dashboard
│   ├── profile/         # Profile
│   └── settings/        # Theme and account settings
└── shared/              # Cross-feature models and shell widgets
assets/
├── images/
├── icons/
└── fonts/
test/
```

## Adding a feature

1. Create a folder under `lib/features/<feature>/` with `data`, `domain`, and `presentation` only when each layer is needed.
2. Define repository contracts in `domain` and provide implementations through Riverpod providers.
3. Add a route in `lib/app/router/app_router.dart`.
4. Reuse `AppButton`, `AppCard`, `AppTextField`, and the shared theme tokens.
5. Add widget or unit coverage under `test/`.

## Architecture notes

- `AuthController` owns auth state and depends on the `AuthRepository` interface.
- `MockAuthRepository` is the only demo-specific auth implementation.
- `Dio` is provided by `apiClientProvider` with centralized base URL and timeouts.
- `ThemeController` persists `system`, `light`, or `dark` in `SharedPreferences`.
- Theme preferences are independent: choose one of four design themes (Modern Minimal, Material 3, Elegant, Bold), five color palettes (Blue, Purple, Green, Orange, Monochrome), and System/Light/Dark appearance mode. All three settings update live and persist locally.
- New branding can be added by extending `AppDesignTheme`, `AppColorScheme`, and `ThemeTokens` in `lib/app/theme/`; screens consume `Theme.of(context)` and shared tokens rather than theme-specific widgets.
- `GoRouter` rebuilds from auth state, keeping the shell routes protected.

## Motion and performance

- Flutter animations use the platform display vsync automatically, so the same code adapts to 60 Hz, 90 Hz, and 120 Hz displays without forcing an unsupported refresh rate. `DisplayPerformance` exposes the current refresh rate and frame budget for diagnostics.
- Page transitions are short, interruptible fade/slide transitions and immediately yield to the OS Reduce Motion accessibility setting.
- Settings includes a persisted Reduce motion option for users who want simpler transitions.
- The dashboard uses lazy scrolling, adaptive pull-to-refresh, const metric content, theme-driven colors, and no blur-heavy effects. Profile performance with `flutter run --profile` on a physical high-refresh-rate device when validating production workloads.

## Loading system

Reusable loading primitives live in `lib/core/widgets/loading/`:

- `AppLoader` supports adaptive/circular spinners, dots, local or remote Lottie, GIF, SVG, image, and custom widgets.
- `AppLoadingOverlay` supports declarative blocking overlays or an `AppLoadingController` with delayed show and minimum display duration.
- `AppSkeleton` and `AppSkeletonCard` provide theme-aware shimmer placeholders with static reduced-motion fallbacks.
- `AppAsyncState<T>` handles loading, success, empty, error, retry, and background refresh while preserving existing content.
- `AppProgressIndicator` exposes determinate progress to screen readers.
- `AppLoadingButton` disables duplicate submissions and preserves button layout while loading.

The Settings developer tools include a Loading playground with native, Lottie, GIF, SVG, skeleton, overlay, progress, button, and simulated async-state examples. Add project-specific JSON, GIF, SVG, or image assets under `assets/animations/`, `assets/icons/`, or `assets/images/`; the shared widgets accept asset paths without changing business logic. Lottie is optional at the feature level, while GIF/network images use Flutter's built-in image pipeline and fallbacks.
- `freezed` and `json_serializable` are intentionally not included until generated immutable models or API DTOs provide real value.

## Platform setup

The project was generated with Flutter’s Android and iOS targets. Android SDK 36 / Java 21, Xcode 26, CocoaPods 1.16.2, Chrome, and macOS desktop are available in the development environment. iOS device deployment still requires a connected, trusted device with Developer Mode enabled and a valid signing team.
