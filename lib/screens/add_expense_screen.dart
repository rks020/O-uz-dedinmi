import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/transaction_options.dart';
import '../theme/app_theme.dart';
import 'currency_selection_screen.dart';
import 'recurrence_selection_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../services/currency_service.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Function(Transaction) onAdd;
  final Function() onAddCategory;

  const AddExpenseScreen({
    super.key,
    required this.onAdd,
    required this.onAddCategory,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TransactionStatus _status = TransactionStatus.pending;
  RecurrenceType _repeat = RecurrenceType.once;
  bool _isFinite = false;
  DateTime _startDate = DateTime.now();
  bool _notificationsEnabled = true;
  String? _selectedCategoryId;
  String _currencyCode = 'TRY';
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final allCategories = categoriesAsync.asData?.value ?? [];
    final expenseCategories = allCategories
        .where((c) => c.type == CategoryType.expense || c.type == CategoryType.both)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Yeni Gider Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: TextButton(
          child: const Text('İptal', style: TextStyle(color: AppTheme.primaryColor)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text('Kaydet', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                final transaction = Transaction(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  amount: double.tryParse(_amountController.text) ?? 0.0,
                  date: _startDate,
                  type: TransactionType.expense,
                  status: _status,
                  categoryId: _selectedCategoryId ?? '',
                  repeat: _repeat,
                  isFinite: _isFinite,
                  notificationEnabled: _notificationsEnabled,
                  currencyCode: _currencyCode,
                  receiptPath: _receiptImage?.path,
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
            const Text('GİDER DETAYLARI', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildTextField('Gider Adı', _titleController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Gider Tutarı', _amountController, isNumber: true)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showCurrencyPicker,
                  child: Container(
                    height: 56, // Match TextField height
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_currencyCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 18),
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
                 activeColor: AppTheme.primaryColor,
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
                          primary: AppTheme.primaryColor,
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
                 activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text('KATEGORİ', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            
            // Budget Warning
            if (_selectedCategoryId != null) (() {
              final cat = expenseCategories.firstWhere((c) => c.id == _selectedCategoryId);
              if (cat.budgetLimit != null) {
                final transactions = ref.watch(monthlyTransactionsProvider);
                final spent = transactions
                    .where((t) => t.categoryId == _selectedCategoryId && t.type == TransactionType.expense)
                    .fold(0.0, (sum, t) => sum + CurrencyService.convertToTry(t.amount, t.currencyCode));
                
                final currentAmount = double.tryParse(_amountController.text) ?? 0.0;
                final willExceed = (spent + currentAmount) > cat.budgetLimit!;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: willExceed ? AppTheme.expenseRed.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: willExceed ? AppTheme.expenseRed.withOpacity(0.3) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori Limiti: ${cat.budgetLimit!.toInt()}₺',
                            style: TextStyle(color: willExceed ? AppTheme.expenseRed : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Harcanan: ${spent.toInt()}₺',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      if (willExceed) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppTheme.expenseRed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bu harcama ile aylık limitinizi ${((spent + currentAmount) - cat.budgetLimit!).toInt()}₺ aşıyorsunuz!',
                                style: const TextStyle(color: AppTheme.expenseRed, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            })(),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Ekle'),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  avatar: const Icon(Icons.add, size: 16, color: Colors.white),
                  backgroundColor: AppTheme.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  onPressed: widget.onAddCategory,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                ...(() {
                  final unique = <String, AppCategory>{};
                  for (var cat in expenseCategories) {
                    final key = cat.name.toLowerCase().trim();
                    if (!unique.containsKey(key)) {
                      unique[key] = cat;
                    }
                  }
                  return unique.values.map((cat) => _buildCategoryChip(cat));
                })(),
              ],
            ),
            const SizedBox(height: 24),
            const Text('FİŞ / FATURA', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickReceipt,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                   borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: _receiptImage != null 
                          ? ClipOval(child: Image.file(_receiptImage!, fit: BoxFit.cover))
                          : const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fiş / Fatura Ekle',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                           if (_receiptImage != null)
                            const Text(
                              'Görüntü seçildi. Değiştirmek için dokunun.',
                              style: TextStyle(color: Colors.green, fontSize: 12),
                            )
                          else
                            Text(
                              'Fotoğraf çekin veya galeriden seçin',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.camera_alt_outlined, color: Colors.grey),
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
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoryChip(AppCategory category) {
    final isSelected = _selectedCategoryId == category.id;
    return FilterChip(
      label: Text(category.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryId = selected ? category.id : null;
        });
      },
      backgroundColor: const Color(0xFF1E1E1E),
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      avatar: CircleAvatar(
        backgroundColor: Color(category.colorValue),
        radius: 6,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1)),
      ),
    );
  }
}
