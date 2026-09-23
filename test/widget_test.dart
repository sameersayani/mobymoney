import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobymoney/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MobyMoneyApp(),
      ),
    );
    expect(find.text('Intelligent Expense Management'), findsOneWidget);
    // Advance the 2800ms splash navigation timer so no timers remain pending
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump();
  });
}



