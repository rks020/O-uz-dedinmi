import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader('HESAP'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.person_outline,
              iconColor: Colors.blue,
              title: 'Hesap',
              subtitle: '${user?.email ?? 'Kullanıcı'} • Ücretsiz Plan',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.grid_view_outlined,
              iconColor: Colors.blueAccent,
              title: 'Çalışma Alanı',
              subtitle: 'Gruplar, kategoriler • Türkçe',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 32),
          _buildSectionHeader('GELİŞİM'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.help_outline,
              iconColor: Colors.blue,
              title: 'Kişisel Finans Testi',
              subtitle: 'Mevcut finansal durumunuzu ölçün',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.article_outlined,
              iconColor: Colors.blueAccent,
              title: 'Yorgan',
              subtitle: 'Maddi gelişim programı',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 32),
          _buildSectionHeader('TERCİHLER VE DESTEK'),
          _buildSettingsGroup([
            _buildSettingsItem(
              icon: Icons.notifications_none_outlined,
              iconColor: Colors.blue,
              title: 'Bildirimler',
              subtitle: 'Aktif • Ödemeden 1 gün önce saat 09:00',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              iconColor: Colors.blueAccent,
              title: 'Görünüm',
              subtitle: 'Sistem • Lacivert',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.security_outlined,
              iconColor: Colors.blue,
              title: 'Veri ve Gizlilik',
              subtitle: 'Para birimi, dışa aktarma, içe aktarma ve gizlilik',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseRed.withOpacity(0.1),
              foregroundColor: AppTheme.expenseRed,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
