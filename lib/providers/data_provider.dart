import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

final transactionsProvider = NotifierProvider<TransactionsNotifier, List<Transaction>>(TransactionsNotifier.new);

class TransactionsNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    return [
      Transaction(
        id: const Uuid().v4(),
        title: 'Kasko',
        amount: 16500,
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: TransactionType.expense,
        status: TransactionStatus.overdue,
        category: 'Sigorta',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Elektrik',
        amount: 600,
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.expense,
        status: TransactionStatus.overdue,
        category: 'Fatura',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Kira',
        amount: 35000,
        date: DateTime.now().subtract(const Duration(days: 10)),
        type: TransactionType.expense,
        status: TransactionStatus.paid,
        category: 'Ev',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Sadık Telefon',
        amount: 275,
        date: DateTime.now().subtract(const Duration(days: 12)),
        type: TransactionType.expense,
        status: TransactionStatus.paid,
        category: 'Fatura',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Aidat',
        amount: 1250,
        date: DateTime.now().subtract(const Duration(days: 15)),
        type: TransactionType.expense,
        status: TransactionStatus.paid,
        category: 'Ev',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Maaş',
        amount: 85000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.income,
        status: TransactionStatus.paid,
        category: 'Maaş',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Freelance',
        amount: 15000,
        date: DateTime.now().add(const Duration(days: 5)),
        type: TransactionType.income,
        status: TransactionStatus.pending,
        category: 'Freelance',
      ),
    ];
  }

  void addTransaction(Transaction t) {
    state = [...state, t];
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void update(DateTime date) => state = date;
}

// Selectors
final monthlyTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final date = ref.watch(selectedDateProvider);
  return transactions
      .where((t) => t.date.year == date.year && t.date.month == date.month)
      .toList();
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final overdueAmountProvider = Provider<double>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  return transactions
      .where((t) =>
          t.status == TransactionStatus.overdue &&
          t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});
