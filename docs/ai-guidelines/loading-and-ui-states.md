# Loading and UI States

Choose the lightest feedback that matches the operation:

- `AppLoader` for compact indeterminate work; supports adaptive/circular/dots, Lottie, GIF, SVG, image, and custom content with fallback.
- `AppLoadingButton` for a submitting action; it disables duplicate taps and preserves layout.
- `AppSkeleton`/`AppSkeletonCard` when content shape is known and the screen should remain usable.
- `AppProgressIndicator` for determinate progress with semantics.
- `AppLoadingOverlay` only when interaction with the visible surface must be blocked; it supports declarative loading and delayed show/minimum duration via `AppLoadingController`.
- `AppLoader.fullScreen` only for genuine app-wide blocking startup work.
- Native Flutter animation is the default; Lottie/GIF/SVG are asset-specific choices, not replacements for every loader.

Use `AppAsyncState<T>` for Riverpod `AsyncValue`: explicit loading, data, empty, error/retry, and background refresh. It preserves existing data while `isRefreshing` and shows a top progress bar. Avoid flicker by not replacing useful data with a full-screen loader for refresh, and avoid indefinite indicators by completing or mapping every async path. Guard cancellation/stale results and disable repeat submissions.

Every state needs meaningful semantics and an actionable error/retry path where appropriate. Do not use mock success in production, swallow errors, block the whole screen for a local operation, or show both competing loaders for one action. Reduced motion must use the static fallbacks already implemented.
