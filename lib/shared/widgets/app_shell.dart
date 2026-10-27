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
    final direction = toCenter >= fromCenter ? 1.0 : -1.0;
    final liquid = Curves.easeInOut.transform(
      math.sin(math.pi * liquidProgress).clamp(0.0, 1.0),
    );
    final stretchWidth = math.min(distance * 0.72, size.width * 0.42);
    final width = 58 + (stretchWidth * liquid);
    final height = 42 - (liquid * 5);
    const centerY = 28.0;
    final radius = height / 2;
    final left = centerX - width / 2;
    final right = centerX + width / 2;
    final top = centerY - height / 2;
    final bottom = centerY + height / 2;
    final headBulge = liquid * 16;
    final tailBulge = liquid * 8;
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(left + radius, top)
      ..cubicTo(
        left + radius + tailBulge,
        top - liquid * 3,
        right - radius - headBulge,
        top - liquid * 3,
        right - radius,
        top,
      )
      ..cubicTo(
        right + (direction > 0 ? headBulge : tailBulge),
        top,
        right + (direction > 0 ? headBulge : tailBulge),
        bottom,
        right - radius,
        bottom,
      )
      ..cubicTo(
        right - radius - headBulge,
        bottom + liquid * 3,
        left + radius + tailBulge,
        bottom + liquid * 3,
        left + radius,
        bottom,
      )
      ..cubicTo(
        left - (direction < 0 ? headBulge : tailBulge),
        bottom,
        left - (direction < 0 ? headBulge : tailBulge),
        top,
        left + radius,
        top,
      )
      ..close();
    canvas.drawPath(path, paint);

    // A smaller trailing drop gives the capsule a soft, liquid pull as it
    // leaves the previous destination.
    if (liquid > 0.02 && distance > 0) {
      final tailX = centerX - direction * (width / 2 - 6);
      canvas.drawCircle(Offset(tailX, centerY), 5 + liquid * 7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidIndicatorPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.liquidProgress != liquidProgress ||
      oldDelegate.fromCenter != fromCenter ||
      oldDelegate.toCenter != toCenter ||
      oldDelegate.color != color;
}
