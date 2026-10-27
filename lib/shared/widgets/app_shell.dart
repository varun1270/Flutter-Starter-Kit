import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = Theme.of(context).extension<MotionTheme>();
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _LiquidNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        motionDuration: motion?.standardDuration ?? AppMotion.standard,
      ),
    );
  }
}

class _LiquidNavigationBar extends StatefulWidget {
  const _LiquidNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.motionDuration,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Duration motionDuration;

  @override
  State<_LiquidNavigationBar> createState() => _LiquidNavigationBarState();
}

class _LiquidNavigationBarState extends State<_LiquidNavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _fromPosition = 0.0;
  var _toPosition = 0.0;

  static const _destinations = [
    (icon: Icons.grid_view_rounded, label: 'Home'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
    (icon: Icons.tune_rounded, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _fromPosition = widget.selectedIndex.toDouble();
    _toPosition = widget.selectedIndex.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: widget.motionDuration,
    );
  }

  @override
  void didUpdateWidget(covariant _LiquidNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motionDuration != widget.motionDuration) {
      _controller.duration = widget.motionDuration;
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Start the next transition from the indicator's current position. This
      // keeps the liquid motion continuous when the user taps quickly.
      final progress = Curves.easeOutCubic.transform(_controller.value);
      _fromPosition += (_toPosition - _fromPosition) * progress;
      _toPosition = widget.selectedIndex.toDouble();
      if (widget.motionDuration == Duration.zero) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border(
            top: BorderSide(color: colors.outline.withValues(alpha: 0.14)),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _destinations.length;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = Curves.easeOutCubic.transform(
                  _controller.value,
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LiquidIndicatorPainter(
                          progress: progress,
                          liquidProgress: _controller.value,
                          fromCenter: itemWidth * (_fromPosition + 0.5),
                          toCenter: itemWidth * (_toPosition + 0.5),
                          color: colors.primary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (
                          var index = 0;
                          index < _destinations.length;
                          index++
                        )
                          Expanded(
                            child: _NavigationDestination(
                              icon: _destinations[index].icon,
                              label: _destinations[index].label,
                              selected: widget.selectedIndex == index,
                              animationProgress: _controller.value,
                              color: colors,
                              onTap: () => widget.onDestinationSelected(index),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.animationProgress,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double animationProgress;
  final ColorScheme color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final jiggleStrength = selected
        ? math.sin(math.pi * animationProgress).clamp(0.0, 1.0)
        : 0.0;
    final jiggleAngle =
        math.sin(animationProgress * math.pi * 3) * jiggleStrength * 0.045;
    final iconScale = selected ? 1.08 + (jiggleStrength * 0.06) : 1.0;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        splashColor: color.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: 84,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, -jiggleStrength * 1.5),
                child: Transform.rotate(
                  angle: jiggleAngle,
                  child: Transform.scale(
                    scale: iconScale,
                    child: Icon(
                      icon,
                      size: 22,
                      color: selected
                          ? color.onPrimary
                          : color.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: selected ? color.primary : color.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidIndicatorPainter extends CustomPainter {
  const _LiquidIndicatorPainter({
    required this.progress,
    required this.liquidProgress,
    required this.fromCenter,
    required this.toCenter,
    required this.color,
  });

  final double progress;
  final double liquidProgress;
  final double fromCenter;
  final double toCenter;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = fromCenter + (toCenter - fromCenter) * progress;
    final distance = (toCenter - fromCenter).abs();
    if (distance < 0.01) {
      _drawRestingPill(canvas, centerX);
      return;
    }

    final direction = toCenter >= fromCenter ? 1.0 : -1.0;
    final phase = Curves.easeInOut.transform(
      math.sin(math.pi * liquidProgress.clamp(0.0, 1.0)).clamp(0.0, 1.0),
    );
    const centerY = 28.0;
    final separation = distance * 0.9 * phase;
    final headX = centerX + direction * separation / 2;
    final tailX = centerX - direction * separation / 2;
    final headRadius = 21 + phase * 4;
    final tailRadius = 21 - phase * 5;
    final paint = Paint()..color = color;
    final path = Path()
      // Top edge: the head pulls away while the tail stays rounded behind it.
      ..moveTo(tailX, centerY - tailRadius)
      ..cubicTo(
        tailX + direction * separation * 0.34,
        centerY - tailRadius,
        headX - direction * separation * 0.24,
        centerY - headRadius,
        headX,
        centerY - headRadius,
      )
      // Leading lobe.
      ..cubicTo(
        headX + direction * headRadius * 0.58,
        centerY - headRadius * 0.72,
        headX + direction * headRadius * 0.58,
        centerY + headRadius * 0.72,
        headX,
        centerY + headRadius,
      )
      // Bottom edge returning to the smaller trailing lobe.
      ..cubicTo(
        headX - direction * separation * 0.24,
        centerY + headRadius,
        tailX + direction * separation * 0.34,
        centerY + tailRadius,
        tailX,
        centerY + tailRadius,
      )
      // Rounded tail lobe.
      ..cubicTo(
        tailX - direction * tailRadius * 0.58,
        centerY + tailRadius * 0.72,
        tailX - direction * tailRadius * 0.58,
        centerY - tailRadius * 0.72,
        tailX,
        centerY - tailRadius,
      )
      ..close();

    // Keep a small drop attached to the back of the moving liquid. It merges
    // with the tail at the peak of the stretch and disappears at rest.
    if (phase > 0.02) {
      canvas.drawCircle(
        Offset(tailX - direction * tailRadius * 0.62, centerY),
        phase * 5,
        paint,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawRestingPill(Canvas canvas, double centerX) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, 28), width: 58, height: 42),
        const Radius.circular(21),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidIndicatorPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.liquidProgress != liquidProgress ||
      oldDelegate.fromCenter != fromCenter ||
      oldDelegate.toCenter != toCenter ||
      oldDelegate.color != color;
}
