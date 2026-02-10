import 'package:flutter/material.dart';

class AppCurrency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  static const List<AppCurrency> currencies = [
    AppCurrency(code: 'TRY', symbol: '₺', name: 'Türk Lirası', flag: '🇹🇷'),
    AppCurrency(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
    AppCurrency(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
    AppCurrency(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
    AppCurrency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
    AppCurrency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
    AppCurrency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
    AppCurrency(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
    AppCurrency(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
  ];

  static String getSymbol(String code) {
    return currencies.firstWhere((c) => c.code == code, orElse: () => currencies[0]).symbol;
  }
}

enum RecurrenceType {
  once,
  everyWeek,
  everyTwoWeeks,
  everyMonth,
  firstWeekdayOfMonth,
  lastWeekdayOfMonth,
  everyDay,
  everyThreeMonths,
  everySixMonths,
  everyYear,
  custom,
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get label {
    switch (this) {
      case RecurrenceType.once:
        return 'Bir kez';
      case RecurrenceType.everyWeek:
        return 'Her hafta';
      case RecurrenceType.everyTwoWeeks:
        return 'Her 2 haftada bir';
      case RecurrenceType.everyMonth:
        return 'Her ay';
      case RecurrenceType.firstWeekdayOfMonth:
        return 'Her ayın ilk hafta içi günü';
      case RecurrenceType.lastWeekdayOfMonth:
        return 'Her ayın son hafta içi günü';
      case RecurrenceType.everyDay:
        return 'Her gün';
      case RecurrenceType.everyThreeMonths:
        return 'Her 3 ayda bir';
      case RecurrenceType.everySixMonths:
        return 'Her 6 ayda bir';
      case RecurrenceType.everyYear:
        return 'Her yıl';
      case RecurrenceType.custom:
        return 'Özel';
    }
  }
}
