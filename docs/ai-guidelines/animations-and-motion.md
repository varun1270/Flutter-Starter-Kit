# Animations and Motion

Motion is centralized in `AppMotion` (`quick` 160ms, `standard` 280ms, `slow` 420ms) and `MotionTheme`, which turns motion off when the app setting or OS `MediaQuery.disableAnimationsOf(context)` requires it.

Use the existing router helpers: auth/detail routes use fade + slide + scale (or native Cupertino on iOS), shell branches use the interruptible `_AnimatedShellContainer`, and `AppShell` uses `LiquidNavigationBar` with a spring-shaped indicator. The profile avatar uses the existing `Hero(tag: 'profile-avatar')`. Do not replace these with generic transitions or add another global motion system.

Animation controllers must have a `TickerProvider`, be disposed, and respond to updated duration/targets. Retarget from the currently painted frame where interaction can happen rapidly, as `LiquidNavigationBar` does. Use `TickerMode`, `Offstage`, `RepaintBoundary`, and `IgnorePointer` consistently with existing branch/indicator behavior. Avoid blur-heavy or unbounded per-frame work; profile with `flutter run --profile` for production-risk animation changes and consider `DisplayPerformance` for diagnostics only.

Reduced motion must snap or use static alternatives: `MotionTheme`, `MediaQuery.disableAnimationsOf`, `AppLoader`, `AppSkeleton`, page transitions, and navigation bar already demonstrate this. Do not invent arbitrary durations/curves or start animation controllers in `build()`.
