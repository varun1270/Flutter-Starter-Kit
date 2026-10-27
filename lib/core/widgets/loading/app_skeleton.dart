import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  AnimationController get _shimmerController =>
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat();

  bool get _reduceMotion {
    final motion = Theme.of(context).extension<MotionTheme>();
    return motion?.reduceMotion ??
        false || MediaQuery.disableAnimationsOf(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surfaceContainer;
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.sm);
    final shape = BoxDecoration(
      color: base,
      borderRadius: widget.shape == BoxShape.rectangle ? radius : null,
      shape: widget.shape,
    );

    final child = _reduceMotion
        ? DecoratedBox(
            decoration: shape,
            child: SizedBox(width: widget.width, height: widget.height),
          )
        : AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, _) => ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(-1.5 + 3 * _shimmerController.value, 0),
                end: Alignment(-0.5 + 3 * _shimmerController.value, 0),
                colors: [base, highlight, base],
                stops: const [0.25, 0.5, 0.75],
              ).createShader(bounds),
              child: DecoratedBox(
                decoration: shape,
                child: SizedBox(width: widget.width, height: widget.height),
              ),
            ),
          );
    return Semantics(label: 'Loading content', child: child);
  }
}

class AppSkeletonText extends StatelessWidget {
  const AppSkeletonText({
    this.width = double.infinity,
    this.height = 14,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      AppSkeleton(width: width, height: height);
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: const [
            AppSkeleton(width: 52, height: 52, shape: BoxShape.circle),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(width: 150),
                  SizedBox(height: AppSpacing.sm),
                  AppSkeletonText(width: 210, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
