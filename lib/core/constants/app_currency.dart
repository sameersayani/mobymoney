/// Supported Currencies in MobyMoney with production-grade metadata
enum AppCurrency {
  inr(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    flag: '🇮🇳',
  ),
  usd(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
    flag: '🇺🇸',
  ),
  gbp(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flag: '🇬🇧',
  ),
  eur(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
  );

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  final String code;
  final String symbol;
  final String name;
  final String flag;

  String get displayName => '$flag $name ($symbol $code)';
  String get shortDisplay => '$code ($symbol)';

  /// Formats major amount (e.g. rupees/dollars) with symbol
  String formatAmount(num amount, {bool decimal = false}) {
    if (decimal) {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
    // Format integer amounts nicely
    final intVal = amount.round();
    final str = intVal.toString();
    // Use standard grouping
    return '$symbol$str';
  }

  /// Formats minor currency units (e.g. paise/cents)
  String formatMinor(int amountMinor, {bool compact = false}) {
    final major = amountMinor / 100.0;
    if (compact && major >= 1000) {
      return '$symbol${(major / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${major.toStringAsFixed(major.truncateToDouble() == major ? 0 : 2)}';
  }

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.inr;
    return AppCurrency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => AppCurrency.inr,
    );
  }
}
