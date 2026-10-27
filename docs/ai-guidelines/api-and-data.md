# API and Data

## Current infrastructure

`apiClientProvider` creates a Dio client with `AppConstants.apiBaseUrl`, a 20-second connect/receive/send timeout, `Accept: application/json`, body-suppressed `LogInterceptor`, and `ref.onDispose(client.close)`. The URL comes from `--dart-define=API_BASE_URL`; the default is the non-production placeholder `https://api.example.com`.

Auth is intentionally mock-only. `MockAuthRepository` delays and returns a demo user; it does not persist credentials or call Dio. `AppException` currently defines `NetworkException` and `AuthException`. No JSON serialization, auth token storage, pagination, caching, upload, retry policy, or permission integration exists yet.

## Adding a real API feature

First obtain and document the backend contract: endpoint, method, headers, auth, request/response schema, pagination, cancellation, and error semantics. Add DTO/model parsing in the feature's `data` layer, a repository contract in `domain`, and a provider-backed implementation in `data`. Inject `Dio` through `apiClientProvider`; never call Dio from a widget or duplicate `BaseOptions`.

Map status/network/parse failures into safe typed exceptions. Do not expose raw response bodies, stack traces, tokens, or server internals to users. Do not log request/response bodies. Retry only idempotent, explicitly retryable failures with bounded backoff; never blindly retry auth or mutations. Add cancellation and pagination semantics only when the contract requires them. Use secure platform storage for secrets when authentication is implemented; `SharedPreferences` is appropriate here for non-sensitive theme preferences, not tokens/passwords.

These production API capabilities are proposed additions, not existing behavior. Keep mock data visibly demo-only and never present it as backend success.
