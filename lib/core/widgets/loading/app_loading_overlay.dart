import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import 'app_loader.dart';

class AppLoadingController extends ChangeNotifier {
  bool _isLoading = false;
  Timer? _delayTimer;
  DateTime? _startedAt;
  int _generation = 0;

  bool get isLoading => _isLoading;

  Future<void> show({Duration delay = Duration.zero}) async {
    final generation = ++_generation;
    _delayTimer?.cancel();
    if (delay > Duration.zero) {
      final completer = Completer<void>();
      _delayTimer = Timer(delay, completer.complete);
      await completer.future;
    }
    if (generation != _generation || _isLoading) return;
    _startedAt = DateTime.now();
    _isLoading = true;
    notifyListeners();
  }

  Future<void> hide({Duration minimumDuration = Duration.zero}) async {
    ++_generation;
    _delayTimer?.cancel();
    if (!_isLoading) return;
    final elapsed = DateTime.now().difference(_startedAt ?? DateTime.now());
    final remaining = minimumDuration - elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    _isLoading = false;
    _startedAt = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    required this.child,
    this.isLoading = false,
    this.controller,
    this.message,
    this.barrierColor,
    this.loader,
    this.semanticsLabel = 'Loading',
    super.key,
  });

  final Widget child;
  final bool isLoading;
  final AppLoadingController? controller;
  final String? message;
  final Color? barrierColor;
  final Widget? loader;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return _build(context, isLoading);
    return ListenableBuilder(
      listenable: controller!,
      builder: (context, _) => _build(context, controller!.isLoading),
    );
  }

  Widget _build(BuildContext context, bool loading) {
    final motion = Theme.of(context).extension<MotionTheme>();
    final loadingWidget =
        loader ?? const AppLoader(style: AppLoaderStyle.adaptive, size: 30);
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          ignoring: !loading,
          child: AnimatedOpacity(
            opacity: loading ? 1 : 0,
            duration: motion?.quickDuration ?? AppMotion.quick,
            child: ColoredBox(
              color:
                  barrierColor ??
                  Theme.of(context).colorScheme.scrim.withValues(alpha: 0.28),
              child: Center(
                child: Semantics(
                  label: semanticsLabel,
                  liveRegion: true,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          loadingWidget,
                          if (message != null) ...[
                            const SizedBox(height: 14),
                            Text(message!, textAlign: TextAlign.center),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
