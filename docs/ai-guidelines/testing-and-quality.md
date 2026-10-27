# Testing and Quality

Supported baseline commands from the repository README are:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run --profile
```

The last command is a profiling workflow, not a pass/fail automated test; use it only when animation/performance risk warrants it. Do not invent commands or report unexecuted results.

Existing tests cover app launch and splash-to-auth landing, home safe-area behavior, loading primitives with reduced motion, and the liquid navigation bar's rest shape, spring stretch, retargeting, jiggle, and reduced-motion snapping. Tests are widget-focused; no repository/provider unit test or HTTP mock suite exists yet.

For new work, test the highest-risk behavior: pure validators/models with unit tests, provider/controller transitions with provider overrides and fake repositories, widget states and semantics, route/redirect behavior, and regression coverage for changed motion or safe areas. Use `SharedPreferences.setMockInitialValues({})` when testing the theme controller/app startup. Prefer injected fakes over live network calls. Exercise loading, success, empty, error, retry, refresh, duplicate-tap, disposal, light/dark, all design themes when relevant, and reduced motion.

Before delivery inspect `git diff`, `git status --short`, and the final file list. A clean analyzer and tests do not prove backend correctness, platform signing, or performance; report those limitations explicitly.
