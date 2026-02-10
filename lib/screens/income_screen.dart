import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_item.dart';
import 'add_income_screen.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(monthlyTransactionsProvider);
    final incomeTransactions = transactions.where((t) => t.type == TransactionType.income).toList();
    final totalIncome = incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final paidIncome = incomeTransactions.where((t) => t.status == TransactionStatus.paid).fold(0.0, (sum, t) => sum + t.amount);
    final remainingIncome = totalIncome - paidIncome;
    
    final selectedDate = ref.watch(selectedDateProvider);
    final isAmountVisible = ref.watch(isAmountVisibleProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Ev giderleri',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isAmountVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.blue,
            ),
            onPressed: () => ref.read(isAmountVisibleProvider.notifier).toggle(),
            style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceColor, shape: const CircleBorder()),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.blue),
            onPressed: () {},
            style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceColor, shape: const CircleBorder()),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              categoriesAsync.whenData((categories) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddIncomeScreen(
                      categories: categories.where((c) => c.type == CategoryType.income || c.type == CategoryType.both).toList(),
                      onAdd: (txn) {
                        ref.read(transactionsControllerProvider).addTransaction(txn);
                      },
                      onAddCategory: () {
                        // Implement category add here if needed
                      },
                    ),
                  ),
                );
              });
            },
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Month Selector
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMonthButton(
                  context, 
                  DateFormat('MMM', 'tr_TR').format(DateTime(selectedDate.year, selectedDate.month - 1)),
                  () => selectedDateNotifier.update(DateTime(selectedDate.year, selectedDate.month - 1)),
                  isPrev: true,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('MMM yyyy', 'tr_TR').format(selectedDate),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildMonthButton(
                  context, 
                  DateFormat('MMM', 'tr_TR').format(DateTime(selectedDate.year, selectedDate.month + 1)),
                  () => selectedDateNotifier.update(DateTime(selectedDate.year, selectedDate.month + 1)),
                  isPrev: false,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: incomeTransactions.isEmpty 
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bu dönem için gelir yok',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Grouped Sections (e.g., Paid)
                    if (paidIncome > 0) ...[
                      _buildStatusSection('Ödenen', paidIncome, incomeTransactions.where((t) => t.status == TransactionStatus.paid).toList()),
                    ],
                    if (incomeTransactions.any((t) => t.status != TransactionStatus.paid)) ...[
                      _buildStatusSection('Bekleyen', totalIncome - paidIncome, incomeTransactions.where((t) => t.status != TransactionStatus.paid).toList()),
                    ],
                    
                    const SizedBox(height: 24),
                    // Summary Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem('Toplam Gelir', totalIncome, currencyFormat, isAmountVisible),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryItem('Kalan Gelir', remainingIncome, currencyFormat, isAmountVisible),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(String title, double amount, List<Transaction> transactions) {
     final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
     return Container(
       margin: const EdgeInsets.only(bottom: 16),
       decoration: BoxDecoration(
         color: AppTheme.surfaceColor.withOpacity(0.5),
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.white.withOpacity(0.05)),
       ),
       child: Theme(
         data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
         child: ExpansionTile(
           initiallyExpanded: true,
           title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
           subtitle: Text(currencyFormat.format(amount), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
           children: transactions.map<Widget>((t) => TransactionItem(transaction: t)).toList(),
         ),
       ),
     );
  }

  Widget _buildSummaryItem(String label, double amount, NumberFormat format, bool isVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          isVisible ? format.format(amount) : '******₺',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMonthButton(BuildContext context, String label, VoidCallback onTap, {required bool isPrev}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isPrev) const Icon(Icons.chevron_left, color: Colors.grey, size: 18),
            Text(label, style: const TextStyle(color: Colors.grey)),
            if (!isPrev) const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

