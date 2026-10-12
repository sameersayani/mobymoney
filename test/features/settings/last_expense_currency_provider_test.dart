import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobymoney/core/constants/app_currency.dart';
import 'package:mobymoney/features/settings/presentation/providers/currency_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('lastExpenseCurrencyProvider initializes and updates currency', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial value defaults to currencyProvider (INR)
    expect(container.read(lastExpenseCurrencyProvider), AppCurrency.inr);

    // Set currency to USD
    await container
        .read(lastExpenseCurrencyProvider.notifier)
        .setCurrency(AppCurrency.usd);

    expect(container.read(lastExpenseCurrencyProvider), AppCurrency.usd);

    // New container should load persisted USD from secure storage once provider is listened to
    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);

    // Listen triggers build() and _loadPersistedCurrency()
    final sub = secondContainer.listen(lastExpenseCurrencyProvider, (_, __) {});
    addTearDown(sub.close);

    await pumpEventQueue();
    expect(secondContainer.read(lastExpenseCurrencyProvider), AppCurrency.usd);
  });
}
