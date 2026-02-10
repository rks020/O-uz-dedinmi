import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../services/currency_service.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/sankey_flow_chart.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _isChartActive = false; // Default to 'Akış' view as requested

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Ev giderleri',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.blue),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMonthButton(
                    DateFormat('MMM', 'tr_TR').format(DateTime(selectedDate.year, selectedDate.month - 1)),
                    () => selectedDateNotifier.update(DateTime(selectedDate.year, selectedDate.month - 1)),
                    isPrev: true,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('MMM yyyy', 'tr_TR').format(selectedDate),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildMonthButton(
                    DateFormat('MMM', 'tr_TR').format(DateTime(selectedDate.year, selectedDate.month + 1)),
                    () => selectedDateNotifier.update(DateTime(selectedDate.year, selectedDate.month + 1)),
                    isPrev: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    _buildToggleItem(0, Icons.account_tree_outlined, 'Akış'),
                    _buildToggleItem(1, Icons.bar_chart_outlined, 'Grafik'),
                  ],
                ),
              ),
            ),
            if (!_isChartActive) ...[
              const SizedBox(height: 32),
              _buildFlowSection(transactionsAsync, categoriesAsync),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.ios_share, color: Colors.blue, size: 24),
                  ),
                ),
              ),
            ] else if (_isChartActive) ...[
              const SizedBox(height: 32),
              _buildChartSection(transactionsAsync),
              const SizedBox(height: 40),
              _buildCategoriesSection(transactionsAsync, categoriesAsync),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSection(AsyncValue<List<Transaction>> transactionsAsync, AsyncValue<List<AppCategory>> categoriesAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        final selectedDate = ref.watch(selectedDateProvider);
        final currentMonthTransactions = transactions.where((t) => t.date.year == selectedDate.year && t.date.month == selectedDate.month).toList();
        final categories = categoriesAsync.value ?? [];

        final income = currentMonthTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + CurrencyService.convertToTry(t.amount, t.currencyCode));
        final expenses = currentMonthTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + CurrencyService.convertToTry(t.amount, t.currencyCode));

        // Group income by categories
        final Map<String, double> incomeMap = {};
        for (var t in currentMonthTransactions.where((t) => t.type == TransactionType.income)) {
          incomeMap[t.categoryId] = (incomeMap[t.categoryId] ?? 0) + CurrencyService.convertToTry(t.amount, t.currencyCode);
        }

        // Group expenses by categories (or just show 'Giderler' if many)
        final Map<String, double> expenseMap = {};
        for (var t in currentMonthTransactions.where((t) => t.type == TransactionType.expense)) {
          expenseMap[t.categoryId] = (expenseMap[t.categoryId] ?? 0) + CurrencyService.convertToTry(t.amount, t.currencyCode);
        }
        
        final List<CategoryVolume> incomeBreakdown = incomeMap.entries.map((e) {
          final cat = categories.firstWhere((c) => c.id == e.key, orElse: () => AppCategory(id: '?', name: 'Gelir', colorValue: Colors.amber.value, type: CategoryType.both));
          return CategoryVolume(name: cat.name, amount: e.value, color: Color(cat.colorValue));
        }).toList();

        // If many expense categories, we might want to group them to keep graph clean
        final List<CategoryVolume> expenseBreakdown = expenseMap.entries.map((e) {
          final cat = categories.firstWhere((c) => c.id == e.key, orElse: () => AppCategory(id: '?', name: 'Gider', colorValue: Colors.red.value, type: CategoryType.both));
          return CategoryVolume(name: cat.name, amount: e.value, color: Color(cat.colorValue));
        }).toList();

        if (income == 0 && expenses == 0) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('Bu ay için akış verisi yok', style: TextStyle(color: Colors.grey))),
          );
        }

        return SankeyFlowChart(
          income: income,
          expenses: expenses,
          incomeBreakdown: incomeBreakdown,
          expenseBreakdown: expenseBreakdown,
        );
      },
      loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 300, child: Center(child: Text('Veri yüklenemedi'))),
    );
  }

  Widget _buildToggleItem(int index, IconData icon, String label) {
    final isActive = (index == 0 && !_isChartActive) || (index == 1 && _isChartActive);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isChartActive = index == 1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(AsyncValue<List<Transaction>> transactionsAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        final selectedDate = ref.watch(selectedDateProvider);
        final List<BarChartGroupData> barGroups = [];
        double maxVal = 1000; // Minimum scale

        // Calculate for the last 6 months ending at selectedDate
        for (int i = 5; i >= 0; i--) {
          final monthDate = DateTime(selectedDate.year, selectedDate.month - i);
          final monthTransactions = transactions.where((t) =>
              t.date.year == monthDate.year && t.date.month == monthDate.month);

          final income = monthTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + CurrencyService.convertToTry(t.amount, t.currencyCode));
          
          final expense = monthTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + CurrencyService.convertToTry(t.amount, t.currencyCode));

          if (income > maxVal) maxVal = income;
          if (expense > maxVal) maxVal = expense;

          barGroups.add(_makeBarGroup(5 - i, income, expense));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Trend Özeti',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2, // 20% padding
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppTheme.surfaceColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toInt().toString() + '₺',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index > 5) return const SizedBox();
                            
                            // Get month relative to selectedDate
                            final targetDate = DateTime(selectedDate.year, selectedDate.month - (5 - index));
                            final text = DateFormat('MMM', 'tr_TR').format(targetDate);
                            
                            return SideTitleWidget(
                              meta: meta, 
                              child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12))
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10));
                            return Text('${(value / 1000).toInt()}K', style: const TextStyle(color: Colors.grey, fontSize: 10));
                          },
                          interval: maxVal > 0 ? (maxVal * 1.2) / 4 : 1000,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(AppTheme.incomeGreen, 'Gelirler'),
                  const SizedBox(width: 24),
                  _buildLegendItem(AppTheme.expenseRed, 'Giderler'),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(height: 200, child: Center(child: Text('Veri yüklenemedi'))),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppTheme.incomeGreen,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: AppTheme.expenseRed,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoriesSection(AsyncValue<List<Transaction>> transactionsAsync, AsyncValue<List<AppCategory>> categoriesAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        final currentMonthTransactions = transactions.where((t) {
          final selectedDate = ref.watch(selectedDateProvider);
          return t.date.year == selectedDate.year && t.date.month == selectedDate.month;
        }).toList();

        final categories = categoriesAsync.value ?? [];
        
        final expenseTransactions = currentMonthTransactions.where((t) => t.type == TransactionType.expense).toList();
        final incomeTransactions = currentMonthTransactions.where((t) => t.type == TransactionType.income).toList();

        if (currentMonthTransactions.isEmpty) {
          return const Center(child: Text('Henüz veri girişi yapılmamış.', style: TextStyle(color: Colors.grey)));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Öne Çıkan Kategoriler',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (expenseTransactions.isNotEmpty) ...[
                const Text('Giderler', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                ..._buildCategoryList(expenseTransactions, categories),
                const SizedBox(height: 24),
              ],
              if (incomeTransactions.isNotEmpty) ...[
                const Text('Gelirler', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                ..._buildCategoryList(incomeTransactions, categories),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.ios_share, color: Colors.blue, size: 20),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
    );
  }

  List<Widget> _buildCategoryList(List<Transaction> transactions, List<AppCategory> categories) {
    final Map<String, double> categoryTotals = {};
    double totalAmount = 0;

    for (var t in transactions) {
      final converted = CurrencyService.convertToTry(t.amount, t.currencyCode);
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + converted;
      totalAmount += converted;
    }

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return categoryTotals.entries.map((entry) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => AppCategory(id: 'other', name: 'Diğer', colorValue: Colors.grey.value, type: CategoryType.both),
      );
      final amount = entry.value;
      final percentageOfTotal = totalAmount > 0 ? (amount / totalAmount * 100).toInt() : 0;
      
      double? budgetProgress;
      Color progressColor = category.colorValue != 0 ? Color(category.colorValue) : AppTheme.primaryColor;
      
      if (category.budgetLimit != null && category.budgetLimit! > 0) {
        budgetProgress = (amount / category.budgetLimit!).clamp(0.0, 1.0);
        if (amount > category.budgetLimit!) {
          progressColor = AppTheme.expenseRed; // Over budget
        } else if (budgetProgress > 0.8) {
          progressColor = Colors.orange; // Warning
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(category.colorValue),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      if (category.budgetLimit != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Limit: ${currencyFormat.format(category.budgetLimit)}',
                             style: TextStyle(
                              color: amount > category.budgetLimit! ? AppTheme.expenseRed : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(amount),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$percentageOfTotal%',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (budgetProgress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budgetProgress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildMonthButton(String label, VoidCallback onTap, {required bool isPrev}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (isPrev) const Icon(Icons.chevron_left, color: Colors.grey, size: 18),
            Text(label, style: const TextStyle(color: Colors.grey)),
            if (!isPrev) const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

