import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_kit/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('home header clears the status bar inset', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 59)),
            child: HomeScreen(),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('YOUR NORTHSTAR')).dy,
      greaterThanOrEqualTo(77),
    );
    expect(tester.takeException(), isNull);
  });
}
