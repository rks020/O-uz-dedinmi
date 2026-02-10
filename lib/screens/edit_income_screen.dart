import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_options.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import 'currency_selection_screen.dart';
import 'recurrence_selection_screen.dart';
import '../widgets/add_category_dialog.dart';

class EditIncomeScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditIncomeScreen({super.key, required this.transaction});

  @override
  ConsumerState<EditIncomeScreen> createState() => _EditIncomeScreenState();
}

class _EditIncomeScreenState extends ConsumerState<EditIncomeScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TransactionStatus _status;
  late RecurrenceType _repeat;
  late bool _isFinite;
  late DateTime _startDate;
  late bool _notificationsEnabled;
  late String? _selectedCategoryId;
  late String _currencyCode;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount.toInt().toString());
    _status = widget.transaction.status;
    _repeat = widget.transaction.repeat;
    _isFinite = widget.transaction.isFinite;
    _startDate = widget.transaction.date;
    _notificationsEnabled = widget.transaction.notificationEnabled;
    _selectedCategoryId = widget.transaction.categoryId;
    _currencyCode = widget.transaction.currencyCode;
  }

  void _showCurrencyPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencySelectionScreen(
          selectedCurrencyCode: _currencyCode,
          onSelected: (currency) {
            setState(() {
              _currencyCode = currency.code;
            });
          },
        ),
      ),
    );
  }

  void _showRecurrencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RecurrenceSelectionScreen(
        selectedRecurrence: _repeat,
        onSelected: (type) {
          setState(() {
            _repeat = type;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Geliri Güncelle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: TextButton(
          child: const Text('İptal', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text('Güncelle', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                final updatedTransaction = widget.transaction.copyWith(
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  date: _startDate,
                  categoryId: _selectedCategoryId ?? '',
                  repeat: _repeat,
                  isFinite: _isFinite,
                  notificationEnabled: _notificationsEnabled,
                  currencyCode: _currencyCode,
                );
                ref.read(transactionsControllerProvider).updateTransaction(updatedTransaction);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GELİR DETAYLARI', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildTextField('maaş', _titleController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('100000', _amountController, isNumber: true)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showCurrencyPicker,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flag, color: Colors.blue, size: 16), // Simplified TR flag
                        const SizedBox(width: 4),
                        Text(_currencyCode, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.blue, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('TARİH VE TEKRAR', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildListTile(
              icon: Icons.repeat,
              title: 'Tekrar',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    _repeat.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                ],
              ),
              onTap: _showRecurrencePicker,
            ),
            _buildListTile(
              icon: Icons.timer,
              title: 'Sonlu Ödeme',
              trailing: Switch(
                value: _isFinite,
                onChanged: (val) => setState(() => _isFinite = val),
                 activeColor: Colors.blue,
              ),
            ),
            _buildListTile(
              icon: Icons.calendar_today,
              title: 'Başlangıç tarihi',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('d MMM yyyy', 'tr_TR').format(_startDate),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                ],
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          surface: AppTheme.surfaceColor,
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('ÖDEME SEÇENEKLERİ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildListTile(
              icon: Icons.notifications_none,
              title: 'Ödeme Bildirimleri',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
                 activeColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text('KATEGORİ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...categories.where((c) => c.type == CategoryType.income || c.type == CategoryType.both).map((cat) => _buildCategoryChip(cat)),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AddCategoryDialog(
                    type: CategoryType.income,
                    onAdd: (category) {
                      ref.read(transactionsControllerProvider).addCategory(category);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppTheme.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoryChip(AppCategory category) {
    final isSelected = _selectedCategoryId == category.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = isSelected ? null : category.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.2) : AppTheme.surfaceColor, // Amber used for income chips often
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Color(category.colorValue),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
