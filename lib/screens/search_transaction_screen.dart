import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item.dart';

class SearchTransactionScreen extends ConsumerStatefulWidget {
  const SearchTransactionScreen({super.key});

  @override
  ConsumerState<SearchTransactionScreen> createState() => _SearchTransactionScreenState();
}

class _SearchTransactionScreenState extends ConsumerState<SearchTransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'İşlem ara...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() {}),
          autofocus: true,
        ),
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tarih',
                  isActive: _selectedDateRange != null,
                  onTap: _pickDateRange,
                  onClear: () => setState(() => _selectedDateRange = null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _selectedType == TransactionType.income ? 'Gelir' : (_selectedType == TransactionType.expense ? 'Gider' : 'Tür'),
                  isActive: _selectedType != null,
                  onTap: () {
                    setState(() {
                      if (_selectedType == null) _selectedType = TransactionType.expense;
                      else if (_selectedType == TransactionType.expense) _selectedType = TransactionType.income;
                      else _selectedType = null;
                    });
                  },
                  onClear: () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: 8),
                if (categoriesAsync.hasValue)
                  _buildCategoryFilter(categoriesAsync.value!),
              ],
            ),
          ),
          
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filtered = _filterTransactions(transactions);
                
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Sonuç bulunamadı',
                          style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return TransactionItem(transaction: filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<AppCategory> categories) {
    final selectedCategory = categories.any((c) => c.id == _selectedCategoryId) 
        ? categories.firstWhere((c) => c.id == _selectedCategoryId) 
        : null;

    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedCategoryId = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('Tümü')),
        ...categories.map((c) => PopupMenuItem(
          value: c.id, 
          child: Row(
            children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(c.name),
            ],
          ),
        )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedCategoryId != null ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _selectedCategoryId != null ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCategory?.name ?? 'Kategori',
              style: TextStyle(
                color: _selectedCategoryId != null ? Colors.white : Colors.grey,
                fontWeight: _selectedCategoryId != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (_selectedCategoryId != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _selectedCategoryId = null),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((t) {
      // Search
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesAmount = t.amount.toString().contains(query);
        if (!matchesTitle && !matchesAmount) return false;
      }

      // Type
      if (_selectedType != null && t.type != _selectedType) return false;

      // Category
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) return false;

      // Date Range
      if (_selectedDateRange != null) {
        if (t.date.isBefore(_selectedDateRange!.start) || t.date.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
