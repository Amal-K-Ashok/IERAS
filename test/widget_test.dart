import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/app.dart';

void main() {
  testWidgets('LoginScreen loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for the widgets to settle
    await tester.pumpAndSettle();

    // Verify that the Login title is displayed
    expect(find.text('Login'), findsOneWidget);

    // Verify that the email and password TextFields are present
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify that the Login button exists
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify that the "Register" link exists
    expect(find.text('Register'), findsOneWidget);
  });
}
