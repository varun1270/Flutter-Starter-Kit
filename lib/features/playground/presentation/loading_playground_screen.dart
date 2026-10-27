import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading/app_async_state.dart';
import '../../../core/widgets/loading/app_loader.dart';
import '../../../core/widgets/loading/app_loading_button.dart';
import '../../../core/widgets/loading/app_loading_overlay.dart';
import '../../../core/widgets/loading/app_progress_indicator.dart';
import '../../../core/widgets/loading/app_skeleton.dart';

class LoadingPlaygroundScreen extends ConsumerStatefulWidget {
  const LoadingPlaygroundScreen({super.key});

  @override
  ConsumerState<LoadingPlaygroundScreen> createState() =>
      _LoadingPlaygroundScreenState();
}

class _LoadingPlaygroundScreenState
    extends ConsumerState<LoadingPlaygroundScreen> {
  AsyncValue<String> _asyncState = const AsyncLoading();
  bool _overlayLoading = false;
  bool _buttonLoading = false;
  double _progress = 0.62;
  int _operation = 0;

  bool get _reduceMotion =>
      Theme.of(context).extension<MotionTheme>()?.reduceMotion ?? false;

  Future<void> _simulate(String result) async {
    final operation = ++_operation;
    setState(() => _asyncState = const AsyncLoading());
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || operation != _operation) return;
    setState(() {
      _asyncState = switch (result) {
        'success' => const AsyncData('Your content loaded successfully.'),
        'empty' => const AsyncData(''),
        _ => AsyncError(
          Exception('The simulated request failed.'),
          StackTrace.current,
        ),
      };
    });
  }

  Future<void> _runButtonAction() async {
    if (_buttonLoading) return;
    setState(() => _buttonLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _buttonLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading playground')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Loading, with intention.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'A development-only reference for choosing the lightest loading experience that fits the operation.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'Inline loaders',
            description:
                'Use compact feedback when the surrounding content remains usable.',
            child: Wrap(
              spacing: 24,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const AppLoader(style: AppLoaderStyle.adaptive, size: 20),
                const AppLoader(style: AppLoaderStyle.circular, size: 24),
                const AppLoader(style: AppLoaderStyle.dots, size: 30),
                AppLoader(
                  style: AppLoaderStyle.custom,
                  size: 30,
                  custom: Icon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  animate: false,
                  semanticsLabel: 'Custom branded loader',
                ),
              ],
            ),
          ),
          _Section(
            title: 'Animation sources',
            description:
                'Lottie, GIF, SVG, static images, and custom widgets share one API.',
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const _LoaderPreview(
                  label: 'Lottie',
                  child: AppLoader(style: AppLoaderStyle.lottie, size: 64),
                ),
                const _LoaderPreview(
                  label: 'SVG',
                  child: AppLoader(style: AppLoaderStyle.svg, size: 54),
                ),
                _LoaderPreview(
                  label: 'GIF / remote',
                  child: AppLoader(
                    style: AppLoaderStyle.gif,
                    size: 54,
                    networkUrl:
                        'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif',
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Skeleton content',
            description:
                'Use stable placeholders for cards and lists instead of blocking the whole screen.',
            child: Column(
              children: [
                const AppSkeletonCard(),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(child: AppSkeleton(height: 84)),
                    SizedBox(width: 10),
                    Expanded(child: AppSkeleton(height: 84)),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            title: 'Async state transitions',
            description:
                'Loading, success, empty, error, retry, and background refresh in one declarative widget.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _simulate('success'),
                      child: const Text('Success'),
                    ),
                    OutlinedButton(
                      onPressed: () => _simulate('empty'),
                      child: const Text('Empty'),
                    ),
                    OutlinedButton(
                      onPressed: () => _simulate('error'),
                      child: const Text('Failure'),
                    ),
                    OutlinedButton(
                      onPressed: () => _simulate('loading'),
                      child: const Text('Retry / load'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 116,
                  child: AppAsyncState<String>(
                    state: _asyncState,
                    isEmpty: (value) => value.isEmpty,
                    data: (value) => Center(child: Text(value)),
                    empty: const Center(child: Text('No results yet.')),
                    loading: const Center(
                      child: AppLoader(style: AppLoaderStyle.dots),
                    ),
                    onRetry: () => _simulate('success'),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Progress and actions',
            description:
                'Progress semantics are exposed to assistive technology, and loading buttons prevent duplicate submissions.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppProgressIndicator(
                  value: _progress,
                  label: 'Upload progress',
                ),
                Slider(
                  value: _progress,
                  onChanged: (value) => setState(() => _progress = value),
                  label: '${(_progress * 100).round()}%',
                ),
                AppLoadingButton(
                  label: 'Simulate save',
                  isLoading: _buttonLoading,
                  onPressed: _runButtonAction,
                ),
              ],
            ),
          ),
          _Section(
            title: 'Blocking overlay',
            description:
                'Use only for operations that must pause interaction with the current surface.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppLoadingOverlay(
                  isLoading: _overlayLoading,
                  message: 'Saving your changes',
                  child: AppCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'The underlying content stays visible while interaction is paused.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _overlayLoading,
                  onChanged: (value) => setState(() => _overlayLoading = value),
                  title: const Text('Show overlay'),
                ),
              ],
            ),
          ),
          AppCard(
            child: SelectableText(
              "AppAsyncState<String>(\n  state: ref.watch(itemsProvider),\n  data: (items) => ItemList(items),\n  isEmpty: (items) => items.isEmpty,\n  onRetry: ref.invalidate(itemsProvider),\n)",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          if (_reduceMotion)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Reduce motion is active: animated loaders use static alternatives.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 5),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LoaderPreview extends StatelessWidget {
  const _LoaderPreview({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [child, const SizedBox(height: 8), Text(label)],
    );
  }
}
