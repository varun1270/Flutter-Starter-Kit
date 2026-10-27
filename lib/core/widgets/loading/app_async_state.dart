import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import 'app_loader.dart';
import 'app_progress_indicator.dart';

class AppAsyncState<T> extends StatelessWidget {
  const AppAsyncState({
    required this.state,
    required this.data,
    this.isEmpty,
    this.empty,
    this.loading,
    this.error,
    this.onRetry,
    this.preserveContentWhileRefreshing = true,
    super.key,
  });

  final AsyncValue<T> state;
  final Widget Function(T value) data;
  final bool Function(T value)? isEmpty;
  final Widget? empty;
  final Widget? loading;
  final Widget? error;
  final VoidCallback? onRetry;
  final bool preserveContentWhileRefreshing;

  @override
  Widget build(BuildContext context) {
    final value = state.value;
    if (value != null) {
      final content = (isEmpty?.call(value) ?? false)
          ? (empty ?? const _DefaultEmptyState())
          : data(value);
      if (state.isRefreshing && preserveContentWhileRefreshing) {
        return Stack(
          children: [
            content,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppProgressIndicator(),
            ),
          ],
        );
      }
      return AnimatedSwitcher(
        duration:
            Theme.of(context).extension<MotionTheme>()?.standardDuration ??
            const Duration(milliseconds: 280),
        child: KeyedSubtree(key: ValueKey(value), child: content),
      );
    }
    if (state.isLoading) return loading ?? const Center(child: AppLoader());
    if (state.hasError) {
      return error ??
          _DefaultErrorState(message: state.error.toString(), onRetry: onRetry);
    }
    return empty ?? const _DefaultEmptyState();
  }
}

class _DefaultEmptyState extends StatelessWidget {
  const _DefaultEmptyState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Nothing here yet'));
}

class _DefaultErrorState extends StatelessWidget {
  const _DefaultErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
