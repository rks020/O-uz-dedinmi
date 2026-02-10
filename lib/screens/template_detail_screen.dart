import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_options.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'edit_income_screen.dart';
import '../widgets/transaction_item.dart';

class TemplateDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  const TemplateDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];
    final category = categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => AppCategory(id: 'other', name: 'Diğer', colorValue: Colors.grey.value, type: CategoryType.both),
    );

    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final currencySymbol = AppCurrency.getSymbol(transaction.currencyCode);
    final amountFormat = NumberFormat.currency(locale: 'tr_TR', symbol: currencySymbol, decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Şablon detayları',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.surfaceColor,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditIncomeScreen(transaction: transaction)),
                );
              } else if (value == 'complete') {
                ref.read(transactionsControllerProvider).updateTransaction(
                  transaction.copyWith(status: TransactionStatus.paid),
                );
                Navigator.pop(context);
              } else if (value == 'delete') {
                ref.read(transactionsControllerProvider).deleteTransaction(transaction.id);
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [Icon(Icons.edit_outlined, color: Colors.white70), SizedBox(width: 12), Text('Şablonu düzenle', style: TextStyle(color: Colors.white))]),
              ),
              const PopupMenuItem(
                value: 'complete',
                child: Row(children: [Icon(Icons.check_circle_outline, color: Colors.blue), SizedBox(width: 12), Text('Ödemeyi tamamla', style: TextStyle(color: Colors.white))]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete_outline, color: AppTheme.expenseRed), SizedBox(width: 12), Text('Sil', style: TextStyle(color: AppTheme.expenseRed))]),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title.toLowerCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTag('Ev giderleri'),
                      const SizedBox(width: 8),
                      _buildTag('Gelir'),
                      const SizedBox(width: 8),
                      _buildTag(category.name),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(Icons.sync, _getRepeatText(transaction.repeat)),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today_outlined, '${dateFormat.format(transaction.date)} tarihinden itibaren'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.account_balance_wallet_outlined, 'Tutar: ', 
                    value: amountFormat.format(transaction.amount), currency: 'TRY'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Overdue Section
            _buildTransactionGroup(
              context, 
              title: 'Geciken', 
              amount: transaction.amount, 
              transactions: [transaction], // Placeholder, logic needed for actual instances
              isOverdue: true
            ),
            const SizedBox(height: 16),
            
            // Future Section
            _buildTransactionGroup(
              context, 
              title: 'Gelecek', 
              amount: transaction.amount * 4, 
              transactions: List.generate(4, (index) => transaction.copyWith(
                date: DateTime(transaction.date.year, transaction.date.month + (index + 1) * 3), // Example recurrence
              )), 
              isOverdue: false
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, {String? value, String? currency}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              if (value != null)
                TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              if (currency != null)
                TextSpan(text: ' $currency', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionGroup(BuildContext context, {required String title, required double amount, required List<Transaction> transactions, required bool isOverdue}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} TRY',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: transactions.map((tx) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isOverdue ? AppTheme.expenseRed.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverdue ? Icons.close : Icons.remove, 
                  color: isOverdue ? AppTheme.expenseRed : Colors.blue, 
                  size: 20
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    Text('${tx.amount.toInt()}₺', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
              ),
              Text(
                DateFormat('d MMM yyyy', 'tr_TR').format(tx.date),
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  String _getRepeatText(RecurrenceType repeat) {
    switch (repeat) {
      case RecurrenceType.everyMonth: return 'Aylık';
      case RecurrenceType.everyWeek: return 'Haftalık';
      case RecurrenceType.once: return 'Tek seferlik';
      case RecurrenceType.everyThreeMonths: return 'Üç aylık';
      default: return repeat.label;
    }
  }
}
