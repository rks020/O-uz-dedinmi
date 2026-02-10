import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
      data: (transactions) {
        return categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Hata: $err')),
          data: (categories) {
            // Calculate category expenses
            final Map<String, double> categoryExpenses = {};
            double totalExpenses = 0;

            for (var t in transactions) {
              if (t.type == TransactionType.expense) {
                final categoryName = categories
                    .firstWhere((c) => c.id == t.categoryId,
                        orElse: () => categories.firstWhere((c) => c.name == 'Diğer', orElse: () => categories.first)) // Fallback
                    .name;
                
                categoryExpenses[categoryName] =
                    (categoryExpenses[categoryName] ?? 0) + t.amount;
                totalExpenses += t.amount;
              }
            }

            final sortedCategories = categoryExpenses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final currencyFormat = NumberFormat.currency(
                locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

            return Scaffold(
              appBar: AppBar(title: const Text('Analiz')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trend Özeti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // ... Chart (unchanged) ...
                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            makeGroupData(0, 12000, 8000),
                            makeGroupData(1, 15000, 10000),
                            makeGroupData(2, 9000, 7000),
                            makeGroupData(3, 11000, 16500),
                            makeGroupData(4, 18000, 12000),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 12, height: 12, color: AppTheme.incomeGreen),
                        const SizedBox(width: 4),
                        const Text("Gelirler"),
                        const SizedBox(width: 16),
                        Container(width: 12, height: 12, color: AppTheme.expenseRed),
                        const SizedBox(width: 4),
                        const Text("Giderler"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('Öne Çıkan Kategoriler',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (sortedCategories.isEmpty)
                      const Text("Henüz veri yok")
                    else
                      ...sortedCategories.map((e) {
                         final percentage = totalExpenses == 0 ? 0.0 : (e.value / totalExpenses);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.category, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(currencyFormat.format(e.value),
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.grey[200],
                                      color: AppTheme.primaryBlue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  BarChartGroupData makeGroupData(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppTheme.incomeGreen,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: AppTheme.expenseRed,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

Widget bottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(color: Colors.grey, fontSize: 10);
  String text;
  switch (value.toInt()) {
    case 0:
      text = 'Haz';
      break;
    case 1:
      text = 'Tem';
      break;
    case 2:
      text = 'Ağu';
      break;
    case 3:
      text = 'Eyl';
      break;
    case 4:
      text = 'Eki';
      break;
    default:
      text = '';
  }
  return SideTitleWidget(
      meta: meta, child: Text(text, style: style));
}
