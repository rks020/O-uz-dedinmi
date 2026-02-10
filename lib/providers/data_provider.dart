import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/group.dart';
import '../models/category.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.transactionsStream;
});

final groupsProvider = StreamProvider<List<Group>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.groupsStream.map((items) => items.map(Group.fromMap).toList());
});

final categoriesProvider = StreamProvider<List<AppCategory>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.categoriesStream.map((items) => items.map(AppCategory.fromMap).toList());
});

// Helper for CRUD operations (since StreamProvider is read-only)
final transactionsControllerProvider = Provider<TransactionsController>((ref) {
  return TransactionsController(ref.watch(databaseServiceProvider));
});

class TransactionsController {
  final DatabaseService _dbService;

  TransactionsController(this._dbService);

  Future<void> addTransaction(Transaction t) async {
    await _dbService.addTransaction(t);
  }

  Future<void> removeTransaction(String id) async {
    await _dbService.deleteTransaction(id);
  }

  Future<void> updateTransaction(Transaction t) async {
    await _dbService.updateTransaction(t);
  }

  Future<void> createGroup(Group group) async {
    await _dbService.createGroup(group.toMap());
  }

  Future<void> deleteGroup(String id) async {
    await _dbService.deleteGroup(id);
  }

  Future<void> addCategory(AppCategory category) async {
    await _dbService.addCategory(category.toMap());
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
  final transactionsAsync = ref.watch(transactionsProvider);
  final date = ref.watch(selectedDateProvider);

  return transactionsAsync.when(
    data: (transactions) => transactions
        .where((t) => t.date.year == date.year && t.date.month == date.month)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
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

enum TransactionDisplayMode { status, category }

final isAmountVisibleProvider = NotifierProvider<AmountVisibilityNotifier, bool>(AmountVisibilityNotifier.new);

class AmountVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
  set value(bool val) => state = val;
}

final displayModeProvider = NotifierProvider<DisplayModeNotifier, TransactionDisplayMode>(DisplayModeNotifier.new);

class DisplayModeNotifier extends Notifier<TransactionDisplayMode> {
  @override
  TransactionDisplayMode build() => TransactionDisplayMode.category;
  
  void toggle() {
    state = state == TransactionDisplayMode.category 
        ? TransactionDisplayMode.status 
        : TransactionDisplayMode.category;
  }

  void setMode(TransactionDisplayMode mode) => state = mode;
}
