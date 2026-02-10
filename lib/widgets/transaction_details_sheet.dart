import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_options.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class TransactionDetailsSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionDetailsSheet({super.key, required this.transaction});

  static void show(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  @override
  ConsumerState<TransactionDetailsSheet> createState() => _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends ConsumerState<TransactionDetailsSheet> {
  late Transaction _tx;
  bool _isPaymentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
  }

  void _addPartialPayment() {
    final newPayment = PaymentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: 0,
      date: DateTime.now(),
    );
    setState(() {
      _tx = _tx.copyWith(
        partialPayments: [..._tx.partialPayments, newPayment],
      );
    });
    ref.read(transactionsControllerProvider).updateTransaction(_tx);
  }

  void _updatePartialPayment(int index, double amount) {
    final updatedPayments = List<PaymentRecord>.from(_tx.partialPayments);
    updatedPayments[index] = PaymentRecord(
      id: updatedPayments[index].id,
      amount: amount,
      date: updatedPayments[index].date,
    );
    setState(() {
      _tx = _tx.copyWith(partialPayments: updatedPayments);
    });
    ref.read(transactionsControllerProvider).updateTransaction(_tx);
  }

  void _removePartialPayment(int index) {
    final updatedPayments = List<PaymentRecord>.from(_tx.partialPayments);
    updatedPayments.removeAt(index);
    setState(() {
      _tx = _tx.copyWith(partialPayments: updatedPayments);
    });
    ref.read(transactionsControllerProvider).updateTransaction(_tx);
  }

  void _toggleStatus() {
    final newStatus = _tx.status == TransactionStatus.paid 
        ? TransactionStatus.pending 
        : TransactionStatus.paid;
    setState(() {
      _tx = _tx.copyWith(status: newStatus);
    });
    ref.read(transactionsControllerProvider).updateTransaction(_tx);
  }

  void _completePayment() {
    setState(() {
      _tx = _tx.copyWith(status: TransactionStatus.paid);
    });
    ref.read(transactionsControllerProvider).updateTransaction(_tx);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = AppCurrency.getSymbol(_tx.currencyCode);
    final dateFormat = DateFormat('d MMM yyyy', 'tr_TR');
    final amountFormat = NumberFormat.currency(locale: 'tr_TR', symbol: currencySymbol, decimalDigits: 0);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _tx.title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          color: AppTheme.surfaceColor,
                          onSelected: (value) {
                            if (value == 'delete') {
                              ref.read(transactionsControllerProvider).deleteTransaction(_tx.id);
                              Navigator.pop(context);
                            } else if (value == 'complete') {
                              _completePayment();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'template_view',
                              child: Row(children: [Icon(Icons.description_outlined, color: Colors.white70), SizedBox(width: 12), Text('Şablonu görüntüle', style: TextStyle(color: Colors.white))]),
                            ),
                            const PopupMenuItem(
                              value: 'template_edit',
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
                    const SizedBox(height: 24),
                    // Status, Date, Amount Row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleStatus,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _tx.status == TransactionStatus.paid ? AppTheme.incomeGreen : AppTheme.expenseRed,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _tx.status == TransactionStatus.paid ? Icons.check : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Text(
                              dateFormat.format(_tx.date),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _tx.amount.toInt().toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(currencySymbol, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Payments Section
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () => setState(() => _isPaymentsExpanded = !_isPaymentsExpanded),
                            title: const Text('Ödemeler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_tx.partialPayments.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('${_tx.partialPayments.length} kayıt', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  ),
                                Icon(_isPaymentsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                              ],
                            ),
                          ),
                          if (_isPaymentsExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'İsteğe bağlı: para aldığınızda kısmi ödemeleri kaydedin.',
                                    style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_tx.partialPayments.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Text(
                                          'Henüz kısmi ödeme yok. Alınan tutarları takip etmek için bir tane ekleyin.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      'TRY ${_tx.paidAmount.toInt()} ödendi · ${_tx.remainingAmount.toInt()} kaldı.',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 16),
                                    ..._tx.partialPayments.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final payment = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.03),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                                ),
                                                child: Text(dateFormat.format(payment.date), style: const TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.03),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                                ),
                                                child: TextField(
                                                  controller: TextEditingController(text: payment.amount.toInt().toString()),
                                                  onSubmitted: (val) => _updatePartialPayment(index, double.tryParse(val) ?? 0),
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () => _removePartialPayment(index),
                                              icon: const Icon(Icons.delete_outline, color: AppTheme.expenseRed),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _addPartialPayment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.05),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, size: 20),
                                        SizedBox(width: 8),
                                        Text('Kısmi ödeme ekle'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
