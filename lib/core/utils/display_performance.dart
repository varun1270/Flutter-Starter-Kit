import 'package:flutter/widgets.dart';

/// Read-only display metrics for diagnostics and performance-sensitive features.
/// Flutter's scheduler already follows the display vsync; this helper is for
/// choosing sensible budgets and reporting what the current device supports.
abstract final class DisplayPerformance {
  static double refreshRate(BuildContext context) {
    return View.of(context).display.refreshRate;
  }

  static Duration frameBudget(BuildContext context) {
    final rate = refreshRate(context).clamp(1, 240);
    return Duration(
      microseconds: (Duration.microsecondsPerSecond / rate).round(),
    );
  }

  static bool supportsHighRefresh(BuildContext context) {
    return refreshRate(context) >= 90;
  }
}
