import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
      bottomNavigationBar: LiquidNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        motionDuration: motion?.standardDuration ?? AppMotion.standard,
      ),
    );
  }
}

/// The shell's navigation surface. Public so its motion can be tested without
/// constructing a router or changing the StatefulShellRoute's branch state.
class LiquidNavigationBar extends StatefulWidget {
  const LiquidNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.motionDuration,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Duration motionDuration;

  @override
  State<LiquidNavigationBar> createState() => _LiquidNavigationBarState();
}

class _LiquidNavigationBarState extends State<LiquidNavigationBar>
    with SingleTickerProviderStateMixin {
  static const _destinations = [
    (icon: Icons.grid_view_rounded, label: 'Home'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
    (icon: Icons.tune_rounded, label: 'Settings'),
  ];
  static const _spring = SpringDescription(
    mass: 0.8,
    stiffness: 320,
    damping: 32,
  );

  late final AnimationController _controller;
  late _LiquidShape _startShape;
  late List<double> _labelStarts;
  late int _targetIndex;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _targetIndex = widget.selectedIndex;
    _startShape = _LiquidShape.rest(_targetIndex);
    _labelStarts = List.generate(
      _destinations.length,
      (index) => index == _targetIndex ? 1 : 0,
    );
    _controller = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        widget.motionDuration == Duration.zero ||
        MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && !_reduceMotion) {
      _snapToSelection();
    }
    _reduceMotion = reduceMotion;
  }

  @override
  void didUpdateWidget(covariant LiquidNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reduceMotion =
        widget.motionDuration == Duration.zero ||
        MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _reduceMotion = true;
      _snapToSelection();
      return;
    }
    _reduceMotion = false;
    if (oldWidget.selectedIndex == widget.selectedIndex) return;

    // Capture all visible geometry and label states before changing the target.
    // A tap during the stretch therefore starts at the exact painted frame.
    _startShape = _shapeAt(_progress);
    _labelStarts = List.generate(_destinations.length, _labelValue);
    _targetIndex = widget.selectedIndex;
    _controller.value = 0;
    _controller.animateWith(
      SpringSimulation(
        _spring,
        0,
        1,
        0,
        tolerance: const Tolerance(distance: 0.001, velocity: 0.001),
      ),
    );
  }

  void _snapToSelection() {
    _controller.stop();
    _targetIndex = widget.selectedIndex;
    _startShape = _LiquidShape.rest(_targetIndex);
    _labelStarts = List.generate(
      _destinations.length,
      (index) => index == _targetIndex ? 1 : 0,
    );
    _controller.value = 1;
  }

  double get _progress => _controller.value.clamp(0.0, 1.0);

  double _labelValue(int index) {
    final t = Curves.easeInOutCubic.transform(_progress);
    return _lerp(_labelStarts[index], index == _targetIndex ? 1 : 0, t);
  }

  _LiquidShape _shapeAt(double t) {
    final target = _targetIndex.toDouble();
    if (t >= 1) return _LiquidShape.rest(_targetIndex);
    final movingRight =
        target >= (_startShape.leftPosition + _startShape.rightPosition) / 2;
    final lead = Curves.easeInOutCubic.transform((t / 0.90).clamp(0.0, 1.0));
    final trail = Curves.easeInOutCubic.transform(
      ((t - 0.10) / 0.90).clamp(0.0, 1.0),
    );
    final leftT = movingRight ? trail : lead;
    final rightT = movingRight ? lead : trail;
    final wave = math.sin(math.pi * t).clamp(0.0, 1.0);
    final squeeze =
        math.sin(math.pi * (t / 0.22).clamp(0.0, 1.0)).clamp(0.0, 1.0) *
        (1 - t);
    final headExtra = 0.8 * wave;
    final tailInset = 1.1 * wave;

    return _LiquidShape(
      leftPosition: _lerp(_startShape.leftPosition, target, leftT),
      rightPosition: _lerp(_startShape.rightPosition, target, rightT),
      leftWidth:
          _lerp(_startShape.leftWidth, 29, t) +
          (movingRight ? -tailInset : headExtra),
      rightWidth:
          _lerp(_startShape.rightWidth, 29, t) +
          (movingRight ? headExtra : -tailInset),
      leftHeight:
          _lerp(_startShape.leftHeight, 21, t) -
          1.5 * squeeze +
          (movingRight ? -0.5 * wave : 0.5 * wave),
      rightHeight:
          _lerp(_startShape.rightHeight, 21, t) -
          1.5 * squeeze +
          (movingRight ? 0.5 * wave : -0.5 * wave),
      bridgeHeight: _lerp(_startShape.bridgeHeight, 21, t) - 4 * wave,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
                final shape = _shapeAt(_progress);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        key: const Key('liquid-indicator'),
                        child: CustomPaint(
                          painter: _LiquidIndicatorPainter(
                            shape: shape,
                            itemWidth: itemWidth,
                            color: colors.primary,
                          ),
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
                              selection: _labelValue(index),
                              jiggleProgress:
                                  _reduceMotion ||
                                      widget.selectedIndex != index ||
                                      !_controller.isAnimating
                                  ? null
                                  : _progress,
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
    required this.selection,
    required this.jiggleProgress,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final double selection;
  final double? jiggleProgress;
  final ColorScheme color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = jiggleProgress;
    final decay = t == null ? 0.0 : math.exp(-2.4 * t) * (1 - t);
    final oscillation = t == null ? 0.0 : math.sin(1.6 * math.pi * t);
    final scale = 1 + 0.04 * selection + 0.23 * decay * oscillation;
    final lift = t == null
        ? 0.0
        : -2.0 *
              math.exp(-1.5 * t) *
              math.sin(1.5 * math.pi * t).abs() *
              (1 - t);
    final rotation = t == null
        ? 0.0
        : 0.035 * math.exp(-3 * t) * math.sin(3 * math.pi * t) * (1 - t);

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
                offset: Offset(0, lift),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      icon,
                      size: 22,
                      color: Color.lerp(
                        color.onSurfaceVariant,
                        color.onPrimary,
                        selection,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Color.lerp(
                    color.onSurfaceVariant,
                    color.primary,
                    selection,
                  ),
                  fontWeight: FontWeight.lerp(
                    FontWeight.w500,
                    FontWeight.w800,
                    selection,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidShape {
  const _LiquidShape({
    required this.leftPosition,
    required this.rightPosition,
    required this.leftWidth,
    required this.rightWidth,
    required this.leftHeight,
    required this.rightHeight,
    required this.bridgeHeight,
  });

  factory _LiquidShape.rest(int index) => _LiquidShape(
    leftPosition: index.toDouble(),
    rightPosition: index.toDouble(),
    leftWidth: 29,
    rightWidth: 29,
    leftHeight: 21,
    rightHeight: 21,
    bridgeHeight: 21,
  );

  final double leftPosition;
  final double rightPosition;
  final double leftWidth;
  final double rightWidth;
  final double leftHeight;
  final double rightHeight;
  final double bridgeHeight;
}

class _LiquidIndicatorPainter extends CustomPainter {
  const _LiquidIndicatorPainter({
    required this.shape,
    required this.itemWidth,
    required this.color,
  });

  final _LiquidShape shape;
  final double itemWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const centerY = 28.0;
    final firstX = (shape.leftPosition + 0.5) * itemWidth;
    final secondX = (shape.rightPosition + 0.5) * itemWidth;
    final firstIsLeft = firstX <= secondX;
    final leftX = firstIsLeft ? firstX : secondX;
    final rightX = firstIsLeft ? secondX : firstX;
    final leftWidth = firstIsLeft ? shape.leftWidth : shape.rightWidth;
    final rightWidth = firstIsLeft ? shape.rightWidth : shape.leftWidth;
    final leftHeight = firstIsLeft ? shape.leftHeight : shape.rightHeight;
    final rightHeight = firstIsLeft ? shape.rightHeight : shape.leftHeight;
    final span = rightX - leftX;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    if (span < 12) {
      // At rest this is exactly a 58 x 42 horizontal pill.
      final centerX = (leftX + rightX) / 2;
      final height = leftHeight + rightHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: leftWidth + rightWidth + span,
            height: height,
          ),
          Radius.circular(height / 2),
        ),
        paint,
      );
      return;
    }

    final leftTip = leftX - leftWidth;
    final rightTip = rightX + rightWidth;
    final leftCrown = leftX - 2;
    final rightCrown = rightX + 2;
    final neck = (leftX + rightX) / 2;
    // Fade the narrower bridge in as the lobes separate, so the outline does
    // not change abruptly when it leaves the compact pill geometry.
    final waist = _lerp(
      (leftHeight + rightHeight) / 2,
      shape.bridgeHeight,
      ((span - 12) / 26).clamp(0.0, 1.0),
    );

    // One closed outline gives the head, narrow bridge, and smaller trailing
    // lobe matching tangents. There are no overlapping paths or hard seams.
    final path = Path()
      ..moveTo(leftTip, centerY)
      ..cubicTo(
        leftTip,
        centerY - leftHeight * 0.72,
        leftX - leftWidth * 0.72,
        centerY - leftHeight,
        leftCrown,
        centerY - leftHeight,
      )
      ..cubicTo(
        leftCrown + span * 0.25,
        centerY - leftHeight,
        neck - span * 0.18,
        centerY - waist,
        neck,
        centerY - waist,
      )
      ..cubicTo(
        neck + span * 0.18,
        centerY - waist,
        rightCrown - span * 0.25,
        centerY - rightHeight,
        rightCrown,
        centerY - rightHeight,
      )
      ..cubicTo(
        rightX + rightWidth * 0.72,
        centerY - rightHeight,
        rightTip,
        centerY - rightHeight * 0.72,
        rightTip,
        centerY,
      )
      ..cubicTo(
        rightTip,
        centerY + rightHeight * 0.72,
        rightX + rightWidth * 0.72,
        centerY + rightHeight,
        rightCrown,
        centerY + rightHeight,
      )
      ..cubicTo(
        rightCrown - span * 0.25,
        centerY + rightHeight,
        neck + span * 0.18,
        centerY + waist,
        neck,
        centerY + waist,
      )
      ..cubicTo(
        neck - span * 0.18,
        centerY + waist,
        leftCrown + span * 0.25,
        centerY + leftHeight,
        leftCrown,
        centerY + leftHeight,
      )
      ..cubicTo(
        leftX - leftWidth * 0.72,
        centerY + leftHeight,
        leftTip,
        centerY + leftHeight * 0.72,
        leftTip,
        centerY,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidIndicatorPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.itemWidth != itemWidth ||
      oldDelegate.color != color;
}

double _lerp(double from, double to, double t) => from + (to - from) * t;
