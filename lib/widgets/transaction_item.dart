import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/transaction_options.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/data_provider.dart';

class TransactionItem extends ConsumerWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    IconData centerIcon;
    Color iconBgColor;
    Color iconColor;

    // Determine styles based on status and type
    switch (transaction.status) {
      case TransactionStatus.overdue:
        statusColor = AppTheme.expenseRed;
        centerIcon = Icons.close;
        iconBgColor = AppTheme.expenseRed;
        iconColor = Colors.white;
        break;
      case TransactionStatus.paid:
        statusColor = AppTheme.incomeGreen;
        centerIcon = Icons.check;
        iconBgColor = AppTheme.incomeGreen;
        iconColor = Colors.white;
        break;
      case TransactionStatus.pending:
        statusColor = AppTheme.accentBlue;
        centerIcon = transaction.type == TransactionType.income 
            ? FontAwesomeIcons.arrowUp 
            : FontAwesomeIcons.arrowDown;
        iconBgColor = AppTheme.backgroundLight;
        iconColor = transaction.type == TransactionType.income 
            ? AppTheme.incomeGreen 
            : AppTheme.expenseRed;
        break;
    }

    final dateFormat = DateFormat('d MMM', 'tr_TR');
    final amountSymbol = AppCurrency.getSymbol(transaction.currencyCode);
    final amountFormat = NumberFormat.currency(locale: 'tr_TR', symbol: amountSymbol, decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor, // Dark surface
        borderRadius: BorderRadius.circular(16),
        // No shadow for dark theme typically, or subtle
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Status Dot
          if (transaction.status == TransactionStatus.overdue || transaction.status == TransactionStatus.pending)
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(24), // Circle
            ),
            child: Icon(
              centerIcon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white, // Text Dark -> White for dark mode
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amountFormat.format(transaction.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateFormat.format(transaction.date), // e.g. 10 Şub
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
