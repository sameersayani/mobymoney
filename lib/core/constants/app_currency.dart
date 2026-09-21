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

  static AppCurrency fromCode(String? code) {
    if (code == null) return AppCurrency.inr;
    return AppCurrency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => AppCurrency.inr,
    );
  }
}
