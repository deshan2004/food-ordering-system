import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_ordering_system/main.dart';

class TestHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = TestHttpOverrides();

  testWidgets('Bonchi food ordering app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodOrderingApp());
    await tester.pumpAndSettle();

    // Verify Bonchi home screen title loads
    expect(find.textContaining('Kohomada, Alex!'), findsOneWidget);
  });
}
