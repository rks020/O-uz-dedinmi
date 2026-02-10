import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Transaction) onAdd;
  final List<AppCategory> categories;
  final Function() onAddCategory;

  const AddExpenseScreen({
    super.key,
    required this.onAdd,
    required this.categories,
    required this.onAddCategory,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  TransactionStatus _status = TransactionStatus.pending;
  RepeatFrequency _repeat = RepeatFrequency.never;
  bool _isFinite = false;
  DateTime _startDate = DateTime.now();
  bool _notificationsEnabled = true;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Yeni Gider Ekle', style: TextStyle(color: Colors.white)),
        leading: TextButton(
          child: const Text('İptal', style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            child: const Text('Kaydet', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              // Validate and save
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
            const Text('GİDER DETAYLARI', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            _buildTextField('Gider Adı', _titleController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Gider Tutarı', _amountController, isNumber: true)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('TRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('TARİH VE TEKRAR', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            _buildListTile(
              icon: Icons.repeat,
              title: 'Tekrar',
              trailing: Text(
                _repeat.name == 'never' ? 'Asla' : _repeat.name,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Show repeat picker
              },
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
              trailing: Text(
                "${_startDate.day} ${_startDate.month} ${_startDate.year}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text('ÖDEME SEÇENEKLERİ', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            _buildListTile(
              icon: Icons.notifications,
              title: 'Ödeme Bildirimleri',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
                 activeColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text('KATEGORİ', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...widget.categories.map((cat) => _buildCategoryChip(cat)),
                ActionChip(
                  label: const Text('Ekle'),
                  avatar: const Icon(Icons.add, size: 16, color: Colors.white),
                  backgroundColor: Colors.blue,
                  labelStyle: const TextStyle(color: Colors.white),
                  onPressed: widget.onAddCategory,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
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
            color: Colors.blue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
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
      selectedColor: Colors.blue.withOpacity(0.5),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
      avatar: CircleAvatar(
        backgroundColor: Color(category.colorValue),
        radius: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3)),
      ),
    );
  }
}
