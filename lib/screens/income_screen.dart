import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import 'add_income_screen.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isAmountVisible = ref.watch(isAmountVisibleProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);

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
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: () {
              categoriesAsync.whenData((categories) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddIncomeScreen(
                      categories: categories.where((c) => c.type == 'income').toList(),
                      onAdd: (txn) {
                        ref.read(transactionsControllerProvider).addTransaction(txn);
                      },
                      onAddCategory: () {
                        // TODO: Implement add category modal
                      },
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
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
                    borderRadius: BorderRadius.circular(16),
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
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bu dönem için gelir yok',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

