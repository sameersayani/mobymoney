import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobymoney/core/constants/app_currency.dart';

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(() {
  return CurrencyNotifier();
});

class CurrencyNotifier extends Notifier<AppCurrency> {
  static const _storageKey = 'selected_currency_code';
  final _storage = const FlutterSecureStorage();

  @override
  AppCurrency build() {
    _loadPersistedCurrency();
    return AppCurrency.inr;
  }

  Future<void> _loadPersistedCurrency() async {
    try {
      final code = await _storage.read(key: _storageKey);
      if (code != null) {
        state = AppCurrency.fromCode(code);
      }
    } catch (_) {}
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    try {
      await _storage.write(key: _storageKey, value: currency.code);
    } catch (_) {}
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Remembers the last selected currency used when creating an expense in AddExpenseDialog
final lastExpenseCurrencyProvider =
    NotifierProvider<LastExpenseCurrencyNotifier, AppCurrency>(() {
  return LastExpenseCurrencyNotifier();
});

class LastExpenseCurrencyNotifier extends Notifier<AppCurrency> {
  static const _storageKey = 'last_expense_currency_code';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  AppCurrency build() {
    _loadPersistedCurrency();
    // Default fallback to whatever default currency is currently active
    return ref.read(currencyProvider);
  }

  Future<void> _loadPersistedCurrency() async {
    try {
      final code = await _storage.read(key: _storageKey);
      if (code != null) {
        state = AppCurrency.fromCode(code);
      }
    } catch (_) {}
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    try {
      await _storage.write(key: _storageKey, value: currency.code);
    } catch (_) {}
  }
}

