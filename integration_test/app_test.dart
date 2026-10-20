import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bio_glow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('basic smoke test - app launches', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('bio glow'), findsOneWidget);
  });
}
