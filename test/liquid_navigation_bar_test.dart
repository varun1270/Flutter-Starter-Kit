import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_kit/shared/widgets/app_shell.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 280),
    bool disableAnimations = false,
  }) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) => LiquidNavigationBar(
                selectedIndex: selectedIndex,
                motionDuration: duration,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('resting shape is a horizontal pill and stretches both ways', (
    tester,
  ) async {
    await pumpBar(tester);
    final home = await indicatorBounds(tester);
    expect(home.width, closeTo(58, 2));
    expect(home.height, closeTo(42, 2));
    expect(home.width, greaterThan(home.height));

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 65));
    final goingRight = await indicatorBounds(tester);
    expect(goingRight.width, greaterThan(home.width + 70));
    expect(
      goingRight.right - home.right,
      greaterThan(goingRight.left - home.left + 70),
    );
    expect(goingRight.height, lessThan(47));
    await tester.pump(const Duration(milliseconds: 60));
    expect((await indicatorBounds(tester)).left, greaterThan(goingRight.left));

    await tester.pumpAndSettle();
    final settings = await indicatorBounds(tester);
    expect(settings.width, closeTo(58, 2));
    expect(settings.height, closeTo(42, 2));
    expect(settings.center.dx, greaterThan(home.center.dx));

    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 65));
    final goingLeft = await indicatorBounds(tester);
    expect(goingLeft.width, greaterThan(settings.width + 70));
    expect(
      settings.left - goingLeft.left,
      greaterThan(settings.right - goingLeft.right + 70),
    );
    expect(goingLeft.height, lessThan(47));
    await tester.pumpAndSettle();
    expect(
      (await indicatorBounds(tester)).center.dx,
      closeTo(home.center.dx, 2),
    );
  });

  testWidgets('rapid taps preserve the current liquid frame', (tester) async {
    await pumpBar(tester);
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    final beforeRetarget = await indicatorBounds(tester);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    final afterRetarget = await indicatorBounds(tester);
    expect(afterRetarget, beforeRetarget);
    await tester.pumpAndSettle();
    expect((await indicatorBounds(tester)).width, closeTo(58, 2));
  });

  testWidgets('new icon has a subtle damped jiggle', (tester) async {
    await pumpBar(tester);
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 25));
    final transforms = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byIcon(Icons.tune_rounded),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(
      transforms.any((transform) => transform.transform.storage[0] > 1.05),
      isTrue,
    );
    expect(
      transforms.any((transform) => transform.transform.storage[13] < -0.2),
      isTrue,
    );
    await tester.pumpAndSettle();
    final settled = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byIcon(Icons.tune_rounded),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(
      settled.any(
        (transform) => (transform.transform.storage[0] - 1.04).abs() < 0.001,
      ),
      isTrue,
    );
  });

  testWidgets('zero motion snaps directly to the destination pill', (
    tester,
  ) async {
    await pumpBar(tester, duration: Duration.zero);
    final home = await indicatorBounds(tester);
    await tester.tap(find.text('Settings'));
    await tester.pump();
    final settings = await indicatorBounds(tester);
    expect(settings.width, closeTo(58, 2));
    expect(settings.height, closeTo(42, 2));
    expect(settings.center.dx, greaterThan(home.center.dx));
  });

  testWidgets('system reduced motion also snaps without a stretch', (
    tester,
  ) async {
    await pumpBar(tester, disableAnimations: true);
    final home = await indicatorBounds(tester);
    await tester.tap(find.text('Profile'));
    await tester.pump();
    final profile = await indicatorBounds(tester);
    expect(profile.width, closeTo(58, 2));
    expect(profile.height, closeTo(42, 2));
    expect(profile.center.dx, greaterThan(home.center.dx));
  });
}

Future<Rect> indicatorBounds(WidgetTester tester) async {
  return (await tester.runAsync(() => _captureIndicatorBounds(tester)))!;
}

Future<Rect> _captureIndicatorBounds(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('liquid-indicator')),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final bytes = data!.buffer.asUint8List();
  var minX = image.width;
  var minY = image.height;
  var maxX = -1;
  var maxY = -1;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (bytes[(y * image.width + x) * 4 + 3] < 128) continue;
      minX = mathMin(minX, x);
      minY = mathMin(minY, y);
      maxX = mathMax(maxX, x);
      maxY = mathMax(maxY, y);
    }
  }
  image.dispose();
  return Rect.fromLTRB(
    minX.toDouble(),
    minY.toDouble(),
    (maxX + 1).toDouble(),
    (maxY + 1).toDouble(),
  );
}

int mathMin(int a, int b) => a < b ? a : b;
int mathMax(int a, int b) => a > b ? a : b;
