import 'package:flutter_test/flutter_test.dart';
import 'package:mobymoney/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MobyMoneyApp());
    expect(find.text('Intelligent Expense Management'), findsOneWidget);
  });
}
