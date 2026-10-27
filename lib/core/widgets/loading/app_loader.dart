import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../app/theme/app_theme.dart';

enum AppLoaderStyle {
  adaptive,
  circular,
  dots,
  lottie,
  gif,
  svg,
  image,
  custom,
}

class AppLoader extends StatefulWidget {
  const AppLoader({
    this.style = AppLoaderStyle.adaptive,
    this.size = 28,
    this.color,
    this.assetPath,
    this.networkUrl,
    this.custom,
    this.message,
    this.animate = true,
    this.loop = true,
    this.semanticsLabel = 'Loading',
    this.onAnimationComplete,
    super.key,
  });

  const AppLoader.fullScreen({
    this.style = AppLoaderStyle.lottie,
    this.size = 112,
    this.color,
    this.assetPath = 'assets/animations/northstar_pulse.json',
    this.networkUrl,
    this.custom,
    this.message,
    this.animate = true,
    this.loop = true,
    this.semanticsLabel = 'Loading application',
    this.onAnimationComplete,
    super.key,
  });

  final AppLoaderStyle style;
  final double size;
  final Color? color;
  final String? assetPath;
  final String? networkUrl;
  final Widget? custom;
  final String? message;
  final bool animate;
  final bool loop;
  final String? semanticsLabel;
  final VoidCallback? onAnimationComplete;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with TickerProviderStateMixin {
  AnimationController? _lottieController;
  AnimationController? _dotsController;
  bool _lottieReady = false;

  AnimationController get _lottieAnimationController =>
      _lottieController ??= AnimationController(vsync: this);

  AnimationController get _dotsAnimationController =>
      _dotsController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );

  bool get _reduceMotion {
    final themeMotion = Theme.of(context).extension<MotionTheme>();
    return themeMotion?.reduceMotion ??
        false || MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _lottieController?.dispose();
    _dotsController?.dispose();
    super.dispose();
  }

  void _updateAnimationState() {
    if (!mounted || _reduceMotion || !widget.animate) {
      _dotsController?.stop();
      if (_lottieReady) _lottieController?.stop();
      return;
    }
    if (widget.style == AppLoaderStyle.dots &&
        !(_dotsController?.isAnimating ?? false)) {
      _dotsAnimationController.repeat();
    }
    if (_lottieReady &&
        widget.style == AppLoaderStyle.lottie &&
        !(_lottieController?.isAnimating ?? false)) {
      if (widget.loop) {
        _lottieAnimationController.repeat();
      } else {
        _lottieAnimationController.forward(from: 0);
      }
    }
  }

  void _onLottieLoaded(LottieComposition composition) {
    _lottieReady = true;
    _lottieAnimationController.duration = composition.duration;
    _lottieAnimationController.removeStatusListener(_onLottieStatus);
    _lottieAnimationController.addStatusListener(_onLottieStatus);
    _updateAnimationState();
  }

  void _onLottieStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !widget.loop) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateAnimationState(),
    );
  }

  @override
  void didUpdateWidget(covariant AppLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style != widget.style ||
        oldWidget.animate != widget.animate ||
        oldWidget.loop != widget.loop) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateAnimationState(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = switch (widget.style) {
      AppLoaderStyle.adaptive => _buildAdaptive(),
      AppLoaderStyle.circular => _buildCircular(),
      AppLoaderStyle.dots => _DotsLoader(
        controller: _dotsAnimationController,
        color: widget.color ?? Theme.of(context).colorScheme.primary,
        size: widget.size,
        reduceMotion: _reduceMotion,
      ),
      AppLoaderStyle.lottie => _buildLottie(),
      AppLoaderStyle.gif => _buildGif(),
      AppLoaderStyle.svg => _buildSvg(),
      AppLoaderStyle.image => _buildImage(),
      AppLoaderStyle.custom => widget.custom ?? _buildCircular(),
    };

    return Semantics(
      label: widget.semanticsLabel,
      liveRegion: true,
      child: widget.message == null
          ? content
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                const SizedBox(height: 14),
                Text(widget.message!, textAlign: TextAlign.center),
              ],
            ),
    );
  }

  Widget _buildAdaptive() {
    return SizedBox.square(
      dimension: widget.size,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: widget.size <= 24 ? 2 : 3,
        valueColor: widget.color == null
            ? null
            : AlwaysStoppedAnimation(widget.color),
      ),
    );
  }

  Widget _buildCircular() {
    return SizedBox.square(
      dimension: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.size <= 24 ? 2 : 3,
        color: widget.color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildLottie() {
    final fallback = _buildCircular();
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) => fallback;
    if (widget.networkUrl != null) {
      return Lottie.network(
        widget.networkUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        controller: _lottieAnimationController,
        animate: false,
        repeat: false,
        onLoaded: _onLottieLoaded,
        errorBuilder: errorBuilder,
      );
    }
    return Lottie.asset(
      widget.assetPath ?? 'assets/animations/northstar_pulse.json',
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      controller: _lottieAnimationController,
      animate: false,
      repeat: false,
      onLoaded: _onLottieLoaded,
      errorBuilder: errorBuilder,
    );
  }

  Widget _buildGif() {
    final image = widget.networkUrl != null
        ? Image.network(
            widget.networkUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildCircular(),
          )
        : Image.asset(
            widget.assetPath ?? '',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildCircular(),
          );
    return RepaintBoundary(child: image);
  }

  Widget _buildSvg() {
    if (widget.networkUrl != null) {
      return SvgPicture.network(
        widget.networkUrl!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _buildCircular(),
      );
    }
    return SvgPicture.asset(
      widget.assetPath ?? 'assets/icons/northstar.svg',
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => _buildCircular(),
    );
  }

  Widget _buildImage() {
    final image = widget.networkUrl != null
        ? Image.network(
            widget.networkUrl!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildCircular(),
          )
        : Image.asset(
            widget.assetPath ?? '',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _buildCircular(),
          );
    return RepaintBoundary(child: image);
  }
}

class _DotsLoader extends StatelessWidget {
  const _DotsLoader({
    required this.controller,
    required this.color,
    required this.size,
    required this.reduceMotion,
  });

  final AnimationController controller;
  final Color color;
  final double size;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.8,
      height: size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final phase = reduceMotion
                  ? 0.5
                  : ((controller.value + index / 3) % 1);
              final scale =
                  0.65 +
                  (0.35 *
                      (0.5 +
                          0.5 *
                              Curves.easeInOut.transform(
                                (phase * 2).clamp(0, 1),
                              )));
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.08),
                child: Transform.scale(
                  scale: scale,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: size * 0.25),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
