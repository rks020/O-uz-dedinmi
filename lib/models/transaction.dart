import 'transaction_options.dart';

enum TransactionType { income, expense }
enum TransactionStatus { pending, paid, overdue }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String categoryId; // Reference to Category ID
  final String? iconPath; // Optional path for svg or resource
  final String? description;
  final RecurrenceType repeat;
  final bool isFinite;
  final DateTime? endDate;
  final bool notificationEnabled;
  final String currencyCode;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.categoryId,
    this.iconPath,
    this.description,
    this.repeat = RecurrenceType.once,
    this.isFinite = false,
    this.endDate,
    this.notificationEnabled = false,
    this.currencyCode = 'TRY',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'categoryId': categoryId,
      'iconPath': iconPath,
      'description': description,
      'repeat': repeat.name,
      'isFinite': isFinite,
      'endDate': endDate?.toIso8601String(),
      'notificationEnabled': notificationEnabled,
      'currencyCode': currencyCode,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      categoryId: map['categoryId'] ?? '',
      iconPath: map['iconPath'],
      description: map['description'],
      repeat: RecurrenceType.values.firstWhere(
        (e) => e.name == map['repeat'],
        orElse: () => RecurrenceType.once,
      ),
      isFinite: map['isFinite'] ?? false,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      notificationEnabled: map['notificationEnabled'] ?? false,
      currencyCode: map['currencyCode'] ?? 'TRY',
    );
  }
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionStatus? status,
    String? categoryId,
    String? iconPath,
    String? description,
    RecurrenceType? repeat,
    bool? isFinite,
    DateTime? endDate,
    bool? notificationEnabled,
    String? currencyCode,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      iconPath: iconPath ?? this.iconPath,
      description: description ?? this.description,
      repeat: repeat ?? this.repeat,
      isFinite: isFinite ?? this.isFinite,
      endDate: endDate ?? this.endDate,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
