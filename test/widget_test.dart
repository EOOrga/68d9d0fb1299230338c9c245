import 'package:bonnier_ops/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('navigates sections and creates a maintenance request', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OperationsApp(initialRoute: '/'));
    await tester.pumpAndSettle();

    expect(find.text(appName), findsWidgets);
    expect(find.text('Operations'), findsOneWidget);

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();
    expect(find.text('Maintenance'), findsOneWidget);

    await tester.tap(find.byKey(const Key('new-request-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('request-title-field')),
      'Check compressor panel',
    );
    await tester.enterText(
      find.byKey(const Key('request-area-field')),
      'Plant',
    );
    await tester.enterText(
      find.byKey(const Key('request-note-field')),
      'Panel is warm after closing shift.',
    );

    await tester.tap(find.byKey(const Key('save-request-button')));
    await tester.pumpAndSettle();

    expect(find.text('Check compressor panel'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-button')));
    await tester.pumpAndSettle();
    expect(find.text('Local storage only'), findsOneWidget);
  });

  testWidgets('opens route-specific screenshot pages', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OperationsApp(initialRoute: '/revenue'));
    await tester.pumpAndSettle();

    expect(find.text('Revenue trend'), findsOneWidget);
  });
}
