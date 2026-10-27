import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:starter_kit/app/theme/app_theme.dart';
import 'package:starter_kit/core/widgets/loading/app_loader.dart';
import 'package:starter_kit/core/widgets/loading/app_progress_indicator.dart';
import 'package:starter_kit/core/widgets/loading/app_skeleton.dart';

void main() {
  testWidgets('loading primitives render with reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [MotionTheme(reduceMotion: true)]),
        home: const Column(
          children: [
            AppLoader(style: AppLoaderStyle.lottie, size: 48),
            AppSkeleton(width: 120, height: 16),
            AppProgressIndicator(value: 0.5),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(find.byType(AppProgressIndicator), findsOneWidget);
  });
}
