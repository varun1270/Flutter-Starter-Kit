# Coding Standards

The primary lint source is `analysis_options.yaml`, which includes `package:flutter_lints/flutter.yaml` with no project-specific overrides. Run `dart format lib test`; use two-space Dart formatting, null safety, `const` constructors/values where possible, lower_snake_case files, UpperCamelCase types, lowerCamelCase members, and descriptive private helpers.

Prefer small composable widgets over large build methods, immutable value objects, exhaustive enum switches, and `Theme.of(context)` over copied presentation constants. Dispose every controller, focus node, subscription, and owned resource. Use `unawaited` only when intentional and safe, as splash does; check `mounted` before post-await UI work.

Keep logging sanitized. Never commit secrets, passwords, tokens, production URLs, generated build output, or credentials. Do not add dependencies or upgrade packages without a concrete need and validation. Do not use `dynamic`, `!`, broad `catch` blocks, `ignore` comments, or placeholder TODO behavior to hide a design problem; if unavoidable, document the narrow reason.

Prohibited: HTTP in widgets; bypassing Riverpod/go_router; duplicate core widgets/providers/repositories/utilities; hardcoded theme/motion values; unrelated refactors; overwriting user changes; invented backend contracts; real production claims for mock data; and claiming checks that were not run.
