import 'package:flutter/material.dart';
import '../models/transaction_options.dart';
import '../theme/app_theme.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final String selectedCurrencyCode;
  final Function(AppCurrency) onSelected;

  const CurrencySelectionScreen({
    super.key,
    required this.selectedCurrencyCode,
    required this.onSelected,
  });

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AppCurrency> _filteredCurrencies = AppCurrency.currencies;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCurrencies);
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = AppCurrency.currencies.where((c) {
        return c.name.toLowerCase().contains(query) || 
               c.code.toLowerCase().contains(query) ||
               c.symbol.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Para Birimi Seç', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Para birimi ara',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'POPÜLER',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.separated(
                itemCount: _filteredCurrencies.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  final isSelected = currency.code == widget.selectedCurrencyCode;

                  return ListTile(
                    leading: Text(currency.flag, style: const TextStyle(fontSize: 24)),
                    title: Text('${currency.code} ${currency.symbol}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
                    onTap: () {
                      widget.onSelected(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
