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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Category Color Dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color(category.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Status Icon Button
            GestureDetector(
              onTap: () {
                final newStatus = isPaid ? TransactionStatus.pending : TransactionStatus.paid;
                ref.read(transactionsControllerProvider).updateTransaction(
                  transaction.copyWith(status: newStatus),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(centerIcon, color: iconColor, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            // Title and Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatAmount(transaction.amount),
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                ],
              ),
            ),
            // Date
            Text(
              dateFormat.format(transaction.date),
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
