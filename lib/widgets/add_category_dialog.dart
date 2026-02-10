import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../models/category.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(AppCategory) onAdd;
  final CategoryType type;

  const AddCategoryDialog({
    super.key,
    required this.onAdd,
    this.type = CategoryType.expense,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _limitController = TextEditingController(); // Added
  int _selectedColor = 0xFFF44336; // Default red

  final List<int> _colors = [
    0xFFF44336, 0xFFE91E63, 0xFF9C27B0, 0xFF673AB7, 0xFF3F51B5, 0xFF2196F3,
    0xFF03A9F4, 0xFF00BCD4, 0xFF009688, 0xFF4CAF50, 0xFF8BC34A, 0xFFCDDC39,
    0xFFFFEB3B, 0xFFFFC107, 0xFFFF9800, 0xFFFF5722, 0xFF795548, 0xFF9E9E9E,
    0xFF607D8B, 0xFFFFFFFF,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.type == CategoryType.income) {
      _selectedColor = 0xFF4CAF50; // Default green for income
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canHaveLimit = widget.type == CategoryType.expense || widget.type == CategoryType.both;

    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // Changed to ScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... header ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.type == CategoryType.income ? 'Yeni Gelir Kategorisi' : 'Yeni Gider Kategorisi',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('Kategori Adı', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Kategori adını girin',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (canHaveLimit) ...[
                const SizedBox(height: 16),
                const Text('Aylık Harcama Limiti (Opsiyonel)', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Örn: 5000',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixText: 'TL',
                     suffixStyle: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // ... existing color picker ...
              const Text('Renk', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    final newCategory = AppCategory(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      colorValue: _selectedColor,
                      type: widget.type,
                      budgetLimit: canHaveLimit && _limitController.text.isNotEmpty 
                          ? double.tryParse(_limitController.text) 
                          : null,
                    );
                    widget.onAdd(newCategory);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

