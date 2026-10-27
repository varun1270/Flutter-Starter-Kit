# State Management

Riverpod 3 is the established state layer (`flutter_riverpod`). Use the provider type that matches the lifecycle and state shape; keep providers close to the feature unless they are app-wide infrastructure.

## Existing patterns

- `NotifierProvider<AuthController, AuthState>` owns synchronous auth state and async commands. `AuthState` is immutable by convention and replaces the whole value for loading, success, and error.
- `AsyncNotifierProvider<ThemeController, ThemeSettings>` models asynchronous preference initialization. It writes optimistic `AsyncData` and persists to `SharedPreferences`.
- `Provider<Dio>` owns one Dio client and closes it with `ref.onDispose`.
- Repositories are injected through providers (`authRepositoryProvider`), so a test can override the implementation.

Widgets use `ConsumerWidget`/`ConsumerStatefulWidget`, `ref.watch` for rendering, and `ref.read(...notifier)` for commands. Use `select` when a large widget only needs a small field. Use `ref.invalidate(provider)` for refresh when the provider itself owns fetching.

```dart
final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final repository = ref.watch(itemsRepositoryProvider);
  return repository.fetchItems();
});

// UI: preserve existing data during refresh when appropriate.
AppAsyncState<List<Item>>(
  state: ref.watch(itemsProvider),
  data: ItemList.new,
  isEmpty: (items) => items.isEmpty,
  onRetry: () => ref.invalidate(itemsProvider),
)
```

Do not put `Future`, Dio calls, or business decisions in `build()`. Do not create a provider inside a widget, mutate a list held in state, use `setState` for cross-screen/application state, or expose a mutable singleton. Cancel/guard work when a screen can be disposed; use `mounted` before UI effects after `await`.

The current auth controller converts `error.toString()` to display text. For new production data flows, prefer typed `AppException` mapping and retain a safe user message plus diagnostic context separately. This is a proposed improvement, not an existing repository-wide convention.
