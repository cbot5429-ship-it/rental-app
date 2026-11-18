import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/common/app_button.dart';
import 'package:flutter_application_1/widgets/common/empty_state.dart';

void main() {
  testWidgets('shared widgets render with the light theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: Column(
            children: [
              const EmptyState(
                icon: Icons.search_off,
                title: 'No Results Found',
                subtitle: 'Try a different search.',
              ),
              AppPrimaryButton(label: 'Continue', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('No Results Found'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  test('both themes expose the property theme extension', () {
    expect(buildLightTheme().extension<PropertyThemeExtension>(), isNotNull);
    expect(buildDarkTheme().extension<PropertyThemeExtension>(), isNotNull);
  });
}
