import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'create_group_sheet.dart';
import 'add_expense_screen.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/transaction_item.dart';
import '../widgets/first_transaction_success_dialog.dart';
import 'groups_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGroupSheet(),
    );
  }

  void _showAddExpenseScreen(BuildContext context) {
    final categoriesAsync = ref.read(categoriesProvider);
    final currentTxns = ref.read(transactionsProvider).asData?.value ?? [];
    final isFirstTransaction = currentTxns.isEmpty;
    
    categoriesAsync.whenData((categories) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(
            categories: categories,
            onAdd: (txn) async {
              await ref.read(transactionsControllerProvider).addTransaction(txn);
              
              if (isFirstTransaction && context.mounted) {
                 showDialog(
                   context: context,
                   barrierColor: Colors.black.withOpacity(0.8),
                   builder: (context) => FirstTransactionSuccessDialog(
                     onContinue: () => Navigator.pop(context),
                   ),
                 );
              }
            },
            onAddCategory: () {
               showDialog(
                context: context,
                builder: (context) => AddCategoryDialog(
                  onAdd: (category) {
                    ref.read(transactionsControllerProvider).addCategory(category);
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
       backgroundColor: AppTheme.backgroundColor,
       body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return _buildEmptyState(context);
          } else {
             return _buildDashboard(context, groups.first.name);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giderler',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showCreateGroupSheet(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Henüz grup yok',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Başlamak için ilk grubunuzu oluşturun',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => _showCreateGroupSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Grup Oluştur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, String groupName) {
     final transactions = ref.watch(monthlyTransactionsProvider);
     final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();
     final isEmpty = expenseTransactions.isEmpty;

     return SafeArea(
       child: Column(
         children: [
           // Custom App Bar
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GroupsScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Text(groupName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                Row(
                   children: [
                     IconButton(
                       icon: Icon(
                         ref.watch(isAmountVisibleProvider) ? Icons.visibility_outlined : Icons.visibility_off_outlined, 
                         color: AppTheme.primaryColor
                       ),
                       onPressed: () => ref.read(isAmountVisibleProvider.notifier).toggle(),
                       style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceColor, shape: const CircleBorder()),
                     ),
                     const SizedBox(width: 8),
                     IconButton(
                       icon: Icon(
                         ref.watch(displayModeProvider) == TransactionDisplayMode.category 
                             ? Icons.sort 
                             : Icons.calendar_today_outlined, 
                         color: AppTheme.primaryColor
                       ),
                       onPressed: () => ref.read(displayModeProvider.notifier).toggle(),
                       style: IconButton.styleFrom(
                         backgroundColor: AppTheme.surfaceColor, 
                         shape: const CircleBorder()
                       ),
                     ),
                     const SizedBox(width: 8),
                     IconButton(
                       icon: const Icon(Icons.add, color: Colors.white),
                       onPressed: () => _showAddExpenseScreen(context),
                       style: IconButton.styleFrom(
                         backgroundColor: AppTheme.primaryColor,
                         shape: const CircleBorder(),
                         padding: const EdgeInsets.all(12),
                       ),
                     ),
                   ],
                 )
               ],
             ),
           ),
           
           if (!isEmpty) ...[
             _buildDashboardContent(context),
           ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'İlk giderini eklemek için tıkla',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bu dönem için ödeme yok',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
           ],
         ],
       ),
     );
  }

  Widget _buildDashboardContent(BuildContext context) {
    // Moved the rest of the dashboard logic here logic from previous _buildDashboard
    final expenseTransactions = ref.watch(monthlyTransactionsProvider).where((t) => t.type == TransactionType.expense).toList();
    final totalExpense = ref.watch(monthlyExpenseProvider);
    final remainingExpense = expenseTransactions.where((t) => t.status != TransactionStatus.paid).fold(0.0, (sum, t) => sum + t.amount);
    final overdueAmount = ref.watch(overdueAmountProvider);
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    final dateFormat = DateFormat('MMM yyyy', 'tr_TR');
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Expanded(
      child: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMonthScrollButton(selectedDate, -1),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    dateFormat.format(selectedDate),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _buildMonthScrollButton(selectedDate, 1),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (overdueAmount > 0) ...[
                  _buildSummaryCard(
                    title: 'Geciken',
                    amount: overdueAmount,
                    color: const Color(0xFF2C1E21),
                    currencyFormat: currencyFormat,
                    isOverdue: true,
                    isVisible: ref.watch(isAmountVisibleProvider),
                  ),
                  const SizedBox(height: 16),
                ],
                ...expenseTransactions.map((tx) => TransactionItem(transaction: tx)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Toplam Gider',
                        amount: totalExpense,
                        color: AppTheme.surfaceColor,
                        currencyFormat: currencyFormat,
                        isVisible: ref.watch(isAmountVisibleProvider),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Kalan Gider',
                        amount: remainingExpense,
                        color: AppTheme.surfaceColor,
                        currencyFormat: currencyFormat,
                        isVisible: ref.watch(isAmountVisibleProvider),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthScrollButton(DateTime selectedDate, int offset) {
    final targetDate = DateTime(selectedDate.year, selectedDate.month + offset);
    final label = DateFormat('MMM', 'tr_TR').format(targetDate);
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedDateProvider.notifier).state = targetDate;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (offset < 0) const Icon(Icons.chevron_left, color: Colors.grey, size: 18),
            Text(label, style: const TextStyle(color: Colors.grey)),
            if (offset > 0) const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required NumberFormat currencyFormat,
    bool isOverdue = false,
    bool isVisible = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isOverdue ? Colors.red[300] : Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isVisible ? currencyFormat.format(amount) : '******${currencyFormat.currencySymbol}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isOverdue)
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
