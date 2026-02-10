import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../models/group.dart';
import '../models/category.dart';
import '../providers/data_provider.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final TextEditingController _nameController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (_nameController.text.trim().isEmpty) return;

    final newGroup = Group(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      createdAt: DateTime.now(),
    );

    final controller = ref.read(transactionsControllerProvider);
    controller.createGroup(newGroup);

    // Seed default categories if needed
    // We can fire and forget this, or use a separate provider check.
    // For simplicity, we'll just add them if we think they might be missing,
    // or rely on the backend/service to do it.
    // Here, we'll manually add a few key categories if we want to ensure they exist.
    // This matches the "Varsayılan kategoriler oluşturulur" promise.
    final defaultCategories = [
      AppCategory(id: _uuid.v4(), name: 'Kira', colorValue: 0xFFFF5722, type: CategoryType.expense, iconCodePoint: Icons.home.codePoint.toString()),
      AppCategory(id: _uuid.v4(), name: 'Faturalar', colorValue: 0xFF2196F3, type: CategoryType.expense, iconCodePoint: Icons.receipt.codePoint.toString()),
      AppCategory(id: _uuid.v4(), name: 'Market', colorValue: 0xFF4CAF50, type: CategoryType.expense, iconCodePoint: Icons.shopping_cart.codePoint.toString()),
      AppCategory(id: _uuid.v4(), name: 'Ulaşım', colorValue: 0xFFFFC107, type: CategoryType.expense, iconCodePoint: Icons.directions_bus.codePoint.toString()),
      AppCategory(id: _uuid.v4(), name: 'Eğlence', colorValue: 0xFF9C27B0, type: CategoryType.expense, iconCodePoint: Icons.movie.codePoint.toString()),
      AppCategory(id: _uuid.v4(), name: 'Diğer', colorValue: 0xFF9E9E9E, type: CategoryType.expense, iconCodePoint: Icons.more_horiz.codePoint.toString()),
    ];

    // Simple check: if we assume this is the *first* group, we probably need categories.
    // Ideally we check database, but adding duplicates might be annoying if ID is random.
    // Strategy: Just add them. If the user already has them, they'll have duplicates or we can check names.
    // Better: Check local provider state.
    final currentCategories = ref.read(categoriesProvider).asData?.value ?? [];
    if (currentCategories.isEmpty) {
      for (var cat in defaultCategories) {
        controller.addCategory(cat);
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Grup Oluştur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance for back button
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group_add, color: AppTheme.primaryColor, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yeni Bir Grup Oluştur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gruplar, aileniz, ev arkadaşlarınız veya ekip üyelerinizle ödemeleri düzenlemenize ve yönetmenize yardımcı olur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Grup adı', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'örn. Ev Giderleri, İş Ödemeleri',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.group_outlined, color: Colors.grey),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Info Cards
            _buildInfoItem(Icons.person_outline, 'Yönetici siz olursunuz',
                'Başkalarını davet edebilir ve grup ayarlarını yönetebilirsiniz.'),
            const SizedBox(height: 16),
            _buildInfoItem(Icons.grid_view, 'Varsayılan kategoriler oluşturulur',
                'Faturalar, kira, market ve daha fazlası otomatik eklenir'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Grup Oluştur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: AppTheme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2), // Reuse primary/blue color
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
