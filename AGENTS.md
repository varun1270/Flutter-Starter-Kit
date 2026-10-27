# AI Development Rules

This is the entry point for AI-assisted work in Northstar Starter Kit. Preserve working behavior and follow the repository's existing patterns before proposing new ones.

## Mandatory first steps

Before editing, inspect the relevant files, `pubspec.yaml`, `analysis_options.yaml`, existing routes, providers, reusable widgets, tests, and `git status`. Trace the affected path from UI to provider/controller to repository/data source and back. Search for an existing component or abstraction before creating one.

Read the detailed guidance that matches the change:

- [Architecture](docs/ai-guidelines/architecture.md)
- [State management](docs/ai-guidelines/state-management.md)
- [Design system](docs/ai-guidelines/design-system.md)
- [Animations and motion](docs/ai-guidelines/animations-and-motion.md)
- [API and data](docs/ai-guidelines/api-and-data.md)
- [Loading and UI states](docs/ai-guidelines/loading-and-ui-states.md)
- [Coding standards](docs/ai-guidelines/coding-standards.md)
- [Testing and quality](docs/ai-guidelines/testing-and-quality.md)
- [AI workflow](docs/ai-guidelines/ai-workflow.md)
- [Feature checklist](docs/ai-guidelines/feature-implementation-checklist.md)

## Non-negotiable architecture rules

- Keep dependencies flowing from presentation to Riverpod state/controllers to domain contracts to data implementations and core infrastructure. Do not put business rules or HTTP calls in widgets.
- Add feature code under `lib/features/<feature>/`; use `data`, `domain`, and `presentation` only when each layer is needed. Put cross-feature primitives in `lib/core` or `lib/shared` according to the existing ownership rules.
- Reuse existing providers, repositories, theme tokens, widgets, loading primitives, validators, and router helpers. Do not create parallel versions.
- Use Riverpod for shared/application state. Keep state immutable and expose explicit loading/error/success behavior. Do not use ad-hoc globals or bypass providers.
- Use `go_router` and the existing protected `StatefulShellRoute`. Add routes in `lib/app/router/app_router.dart`; preserve branch state, redirects, gestures, and motion behavior.
- Consume `Theme.of(context)`, `ColorScheme`, `TextTheme`, `AppSpacing`, `AppRadii`, `ThemeTokens`, and `MotionTheme`. Screens must work with all four design themes, six color schemes, light/dark/system appearance, and reduced motion. Never hardcode a presentation color, spacing, typography, URL, or arbitrary animation duration when a project token exists.
- Treat `MockAuthRepository` as demo behavior, never as production authentication or real backend data. Do not claim a backend-backed feature is complete without a verified contract and implementation.
- Map failures deliberately; never swallow exceptions or leave a loading state active. Do not log credentials, tokens, request bodies, or sensitive response data.

## Scope and change safety

Make the smallest complete change. Preserve user modifications and do not refactor unrelated files, upgrade unrelated dependencies, or introduce a competing architecture. If a backend contract, permission, or product decision is missing, state the assumption and stop short of inventing behavior. Label proposed improvements separately from established conventions.

## Validation and definition of done

Run the relevant checks from [Testing and quality](docs/ai-guidelines/testing-and-quality.md), normally:

```bash
dart format lib test
flutter analyze
flutter test
```

Only report checks that were actually run. A feature is done when its acceptance criteria are implemented, existing patterns and themes remain intact, loading/empty/error/success paths are handled, routes and motion are integrated, tests cover the risk, and the final review finds no unrelated changes or placeholders.

## Required final report

Report: files changed; behavior added or changed; architecture/data-flow decisions; tests and commands actually run with results; assumptions, known gaps, and any follow-up required. Never claim real API integration, security, performance, or build verification without evidence.
