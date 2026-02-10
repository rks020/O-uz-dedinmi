import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/transaction_options.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/data_provider.dart';
import 'transaction_details_sheet.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final category = categories.firstWhere((c) => c.id == transaction.categoryId, 
      orElse: () => AppCategory(id: '', name: 'Kategori', colorValue: Colors.grey.value, type: CategoryType.expense));

    final isPaid = transaction.status == TransactionStatus.paid;
    final isOverdue = transaction.status == TransactionStatus.overdue;
    final isVisible = ref.watch(isAmountVisibleProvider);
    final displayMode = ref.watch(displayModeProvider);
    
    final statusColor = isPaid ? AppTheme.incomeGreen : AppTheme.expenseRed;
    final centerIcon = isPaid ? Icons.check : Icons.close;
    final iconBgColor = isPaid ? AppTheme.incomeGreen : AppTheme.expenseRed;
    final iconColor = Colors.white;

    final dateFormat = DateFormat('d MMM', 'tr_TR');
    final amountSymbol = AppCurrency.getSymbol(transaction.currencyCode);
    final amountFormat = NumberFormat.currency(locale: 'tr_TR', symbol: amountSymbol, decimalDigits: 0);

    String topLabel;
    if (displayMode == TransactionDisplayMode.category) {
      topLabel = category.name;
    } else {
      topLabel = isPaid ? 'Ödenen' : 'Geciken';
    }

    String formatAmount(double value) {
      return isVisible ? amountFormat.format(value) : '******$amountSymbol';
    }

    return GestureDetector(
      onTap: () => TransactionDetailsSheet.show(context, transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOverdue ? const Color(0xFF2C1E21) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Label and Kalan Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Text(
                  'Kalan',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Middle row: Amount and Remaining Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatAmount(transaction.amount),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  isPaid ? formatAmount(0) : formatAmount(transaction.amount),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            const SizedBox(height: 12),
            // Bottom row: Indicator, Button, Title, Date
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isPaid ? AppTheme.incomeGreen : AppTheme.expenseRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    final newStatus = isPaid ? TransactionStatus.pending : TransactionStatus.paid;
                    ref.read(transactionsControllerProvider).updateTransaction(
                      transaction.copyWith(status: newStatus),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(centerIcon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        formatAmount(transaction.amount),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  dateFormat.format(transaction.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
