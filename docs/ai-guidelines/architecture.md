# Architecture

## Verified structure

```text
lib/app/       app root, router, theme, persisted theme controller
lib/core/      constants, errors, network client, validators, reusable UI/loading
lib/features/  auth, home, profile, settings, playground; each is feature-owned
lib/shared/    cross-feature models and the authenticated shell/splash widgets
assets/        icons and animations currently present; pubspec also declares images/
test/          widget and rendering behavior tests
```

The repository currently has `presentation` in every feature, `domain` and `data` in auth, and no home/profile/settings repositories. Do not create empty layers for symmetry.

## Dependency direction

Presentation widgets read Riverpod state and call controller methods. Controllers depend on domain contracts. Data implementations satisfy those contracts and may depend on core network/errors. Core must not import a feature. Shared code is for genuinely cross-feature types/widgets, not a dumping ground.

The current auth flow is: `LoginScreen`/`RegisterScreen`/`ForgotPasswordScreen` -> `authControllerProvider` -> `AuthController` -> `AuthRepository` -> `MockAuthRepository` -> `AuthUser`, with errors returned to the controller and rendered by the screen. `ProfileScreen` and `HomeScreen` consume the auth state. Theme flow is `ThemeController` -> `SharedPreferences` -> `ThemeSettings` -> `StarterKitApp` -> `AppTheme`/`MotionTheme`.

## Adding files

Use lower_snake_case Dart filenames and matching UpperCamelCase types. Add a new feature at `lib/features/<name>/`. Define a domain repository interface only when the feature has a meaningful boundary; put implementations in `data/`, controllers/providers and screens in `presentation/`. Add shared domain models to `lib/shared/models/` only when multiple features own/use them.

Do not add service locators, a second network client, generated model tooling, or a new state-management package. `freezed` and `json_serializable` are not dependencies today; propose them only if real generated DTO/state volume justifies the dependency.

## Route rules

Use `GoRoute` and the existing `StatefulShellRoute` branches. Public routes are currently splash, login, register, and forgot-password; shell routes are home, profile, and settings. Preserve `context.go` for replacement/auth redirects and `context.push` for detail navigation. Use `_authPage`/`_detailPage` or a carefully justified equivalent so transitions remain consistent.
