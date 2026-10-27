# Feature Implementation Checklist

## Before coding

- [ ] Write acceptance criteria, including loading, empty, error, retry/refresh, accessibility, and responsive behavior.
- [ ] Check `git status`; inspect the closest feature, route, provider, model, repository, shared widget, theme, asset, and test.
- [ ] Trace the existing UI -> provider/controller -> domain -> data/infrastructure path.
- [ ] Search for reusable widgets, tokens, validators, loaders, motion, and route helpers before adding anything.

## Design and implementation

- [ ] Place files under `lib/features/<feature>/` with only the layers actually needed.
- [ ] Define immutable state and a Riverpod provider/controller; inject repositories through providers.
- [ ] Keep business logic and network calls out of widgets; use `AuthRepository`/Dio patterns for data boundaries.
- [ ] Confirm any API contract instead of inventing endpoints, schemas, auth, pagination, or retry behavior.
- [ ] Use `Theme.of(context)`, `ColorScheme`, `TextTheme`, `AppSpacing`, `AppRadii`, and existing core widgets.
- [ ] Verify light/dark, all relevant design themes and palettes, system appearance, text scaling, safe areas, and narrow/wide layouts.
- [ ] Add route/navigation integration through `app_router.dart`; preserve shell branches, back behavior, gestures, and existing transition helpers.
- [ ] Reuse `MotionTheme`/`AppMotion`; dispose controllers and honor OS/app reduced motion.
- [ ] Use the appropriate inline loader, skeleton, button loader, progress, overlay, or async-state wrapper. Prevent flicker, stale results, and duplicate submissions.
- [ ] Add semantics, tooltips, labels, contrast, and keyboard/focus behavior for interactive content.

## Verification

- [ ] Add unit/provider/widget/regression tests for the risk and every important async state.
- [ ] Run `dart format lib test`, `flutter analyze`, and `flutter test` as applicable.
- [ ] Run profile/build/platform checks only when relevant, and report exactly what ran.
- [ ] Review `git diff` for hardcoded styles, duplicate abstractions, secrets, placeholders, unrelated edits, and user-change loss.
- [ ] Confirm no documentation claims a proposed or unexecuted behavior is established or verified.

## Final report

- [ ] List changed files and behavior.
- [ ] Explain provider/repository/data-flow decisions.
- [ ] List commands and results.
- [ ] State assumptions, limitations, unimplemented backend/platform work, and follow-up items.
