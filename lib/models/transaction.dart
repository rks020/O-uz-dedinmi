enum TransactionType { income, expense }

enum TransactionStatus { pending, paid, overdue }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String category;
  final String? iconPath; // For SVG icons, or replace with FontAwesome

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    required this.category,
    this.iconPath,
  });
}
