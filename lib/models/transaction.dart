import 'transaction_options.dart';

enum TransactionType { income, expense }
enum TransactionStatus { pending, paid, overdue }

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime date;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String categoryId;
  final String? iconPath;
  final String? description;
  final RecurrenceType repeat;
  final bool isFinite;
  final DateTime? endDate;
  final bool notificationEnabled;
  final String currencyCode;
  final List<PaymentRecord> partialPayments;
  final String? receiptPath; // Added receipt path

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
    this.partialPayments = const [],
    this.receiptPath,
  });

  double get paidAmount => partialPayments.fold(0, (sum, p) => sum + p.amount);
  double get remainingAmount => amount - paidAmount;

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
      'partialPayments': partialPayments.map((p) => p.toMap()).toList(),
      'receiptPath': receiptPath,
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
      partialPayments: (map['partialPayments'] as List?)
              ?.map((p) => PaymentRecord.fromMap(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      receiptPath: map['receiptPath'],
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
    List<PaymentRecord>? partialPayments,
    String? receiptPath,
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
      partialPayments: partialPayments ?? this.partialPayments,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }
}

