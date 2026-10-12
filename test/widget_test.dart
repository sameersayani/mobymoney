import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobymoney/core/services/connectivity_service.dart';
import 'package:mobymoney/features/splash/presentation/splash_screen.dart';
import 'package:mobymoney/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        connectivityProvider.overrideWith(() => _MockConnectivityNotifier()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MobyMoneyApp(),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 500));
  });
}

class _MockConnectivityNotifier extends ConnectivityNotifier {
  @override
  ConnectivityStatus build() => ConnectivityStatus.isConnected;
}



