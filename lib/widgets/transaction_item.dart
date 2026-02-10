import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (transaction.status) {
      case TransactionStatus.overdue:
        statusColor = AppTheme.expenseRed;
        statusIcon = Icons.close;
        break;
      case TransactionStatus.paid:
        statusColor = AppTheme.incomeGreen;
        statusIcon = Icons.check;
        break;
      case TransactionStatus.pending:
        statusColor = AppTheme.accentBlue;
        statusIcon = Icons.circle; // Or a dot
        break;
    }

    final dateFormat = DateFormat(
        'EEE, d', 'tr_TR'); // Requires intl initialization with locale
    final amountFormat =
        NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.type == TransactionType.income
                  ? FontAwesomeIcons.arrowUp
                  : FontAwesomeIcons.arrowDown,
              color: transaction.type == TransactionType.income
                  ? AppTheme.incomeGreen
                  : AppTheme.expenseRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  transaction.category, // e.g. "Fatura"
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountFormat.format(transaction.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    dateFormat.format(transaction.date),
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (transaction.status == TransactionStatus.pending)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle))
                  else
                    Icon(statusIcon, color: statusColor, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
