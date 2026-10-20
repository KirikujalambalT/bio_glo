import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bio_glow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    // remove any mock handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, null);
  });

  testWidgets(
    'create profile, complete quiz, and open skin guides',
    (WidgetTester tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(imagePickerChannel, (
            MethodCall method,
          ) async {
            if (method.method == 'pickImage' ||
                method.method == 'pickImagePath') {
              return '/mock/test_capture.jpg';
            }
            return null;
          });

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // verify brand and Log in
      expect(find.text('bio glow'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      // Create the first local profile.
      await tester.tap(find.text('New to Bio Glow? Create an account'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      // quiz should appear
      expect(find.text('Let us get to know your skin'), findsOneWidget);

      // fill through all quiz pages
      for (int i = 0; i < 12; i++) {
        // enter some text
        final fieldFinder = find.byType(TextField).first;
        await tester.enterText(fieldFinder, 'answer $i');
        await tester.pumpAndSettle();
        // press Continue or See my skin profile
        final continueFinder = find.textContaining('Continue');
        if (continueFinder.evaluate().isNotEmpty) {
          await tester.tap(continueFinder.first);
        } else {
          final finalBtn = find.text('See my skin profile');
          if (finalBtn.evaluate().isNotEmpty) await tester.tap(finalBtn);
        }
        await tester.pumpAndSettle();
      }

      // Now on concerns page
      expect(find.text('Tell us what you notice'), findsOneWidget);

      // Tap camera area to trigger pickImage
      final enableCamera = find.textContaining('Enable camera');
      expect(enableCamera, findsOneWidget);
      await tester.tap(enableCamera.first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'I think I have acne');

      // Match an explicitly named guide without claiming a photo diagnosis.
      await tester.ensureVisible(find.text('Find guides from my description'));
      await tester.tap(find.text('Find guides from my description'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        find.text('Guide topics mentioned in your description'),
        findsOneWidget,
      );
      expect(find.text('General self-care ideas'), findsOneWidget);
      expect(find.textContaining('non-comedogenic'), findsOneWidget);
      expect(
        find.textContaining('your photo was not used to select them'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Tell us what you notice'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'answer 0',
      );
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
