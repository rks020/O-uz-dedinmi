import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../widgets/overview_card.dart';
import '../widgets/transaction_item.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(monthlyTransactionsProvider);
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpense = ref.watch(monthlyExpenseProvider);
    final overdueAmount = ref.watch(overdueAmountProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    final currencyFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).update(
                    DateTime(selectedDate.year, selectedDate.month - 1));
              },
            ),
            Text(
              DateFormat('MMM yyyy', 'tr_TR').format(selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                ref.read(selectedDateProvider.notifier).update(
                    DateTime(selectedDate.year, selectedDate.month + 1));
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  OverviewCard(
                    title: 'Geciken',
                    amount: currencyFormat.format(overdueAmount),
                    color: AppTheme.expenseRed,
                    icon: Icons.warning_rounded,
                  ),
                  OverviewCard(
                    title: 'Toplam Gider',
                    amount: currencyFormat.format(totalExpense),
                    color: AppTheme.primaryBlue,
                    icon: Icons.trending_down,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction = expenseTransactions[index];
                  return TransactionItem(transaction: transaction);
                },
                childCount: expenseTransactions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 80)), // Bottom padding for FAB
        ],
      ),
    );
  }
}
