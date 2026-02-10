import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added import
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/transaction_options.dart';
import '../theme/app_theme.dart';
import 'currency_selection_screen.dart';
import 'recurrence_selection_screen.dart';
import '../providers/data_provider.dart'; // Added for transactionsControllerProvider

class AddIncomeScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  final Function(Transaction) onAdd;
  final List<AppCategory> categories;
  final Function() onAddCategory;

  const AddIncomeScreen({
    super.key,
    required this.onAdd,
    required this.categories,
    required this.onAddCategory,
  });

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState(); // Changed to ConsumerState
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> { // Changed to ConsumerState
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TransactionStatus _status = TransactionStatus.pending;
  RecurrenceType _repeat = RecurrenceType.once;
  bool _isFinite = false;
  DateTime _startDate = DateTime.now();
  bool _notificationsEnabled = true;
  String? _selectedCategoryId;
  String _currencyCode = 'TRY';

  // Define default categories here
  final List<AppCategory> _defaultIncomeCategories = [
    AppCategory(id: 'inc_maas', name: 'Maaş', colorValue: 0xFFF59E0B, type: CategoryType.income),
    AppCategory(id: 'inc_bonus', name: 'Bonus', colorValue: 0xFF10B981, type: CategoryType.income),
    AppCategory(id: 'inc_diger_i', name: 'Diğer', colorValue: 0xFF6B7280, type: CategoryType.income),
  ];

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
    // Combine existing categories with defaults if they are missing
    final List<AppCategory> displayCategories = [...widget.categories];
    for (var def in _defaultIncomeCategories) {
      if (!displayCategories.any((c) => c.name == def.name && c.type == def.type)) {
        displayCategories.add(def);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Yeni Gelir Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: TextButton(
          child: const Text('İptal', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text('Kaydet', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                // Check if selected category is a default one that needs creation
                if (_selectedCategoryId != null) {
                  final selectedCat = displayCategories.firstWhere((c) => c.id == _selectedCategoryId);
                  final exists = widget.categories.any((c) => c.id == selectedCat.id);
                  if (!exists) {
                     ref.read(transactionsControllerProvider).addCategory(selectedCat);
                  }
                }

                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  date: _startDate,
                  type: TransactionType.income,
                  status: _status,
                  categoryId: _selectedCategoryId ?? '',
                  repeat: _repeat,
                  isFinite: _isFinite,
                  notificationEnabled: _notificationsEnabled,
                  currencyCode: _currencyCode,
                );
                widget.onAdd(transaction);
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
            _buildTextField('Gelir Adı', _titleController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Gelir Tutarı', _amountController, isNumber: true)),
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
                        const Icon(Icons.flag, color: Colors.blue, size: 16),
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
                ...displayCategories.map((cat) => _buildCategoryChip(cat)),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onAddCategory,
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
          color: isSelected ? Colors.blue.withOpacity(0.2) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
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
