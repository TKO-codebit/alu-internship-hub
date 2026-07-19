import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_launchpad/core/constants/app_constants.dart';
import 'package:campus_launchpad/core/theme/app_theme.dart';
import 'package:campus_launchpad/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding screen renders ALU branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const OnboardingScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('ALU Ecosystem'), findsOneWidget);
  });
}
