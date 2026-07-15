import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageOrg = ref.watch(authProvider).canManageOrg;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.person_outline,
            title: 'Profil Saya',
            subtitle: 'Nama, no. HP, ganti password',
            route: '/settings/profile',
          ),
          _Tile(
            icon: Icons.storefront_outlined,
            title: 'Organisasi',
            subtitle: 'Nama usaha, alamat, logo',
            route: '/settings/organization',
          ),
          _Tile(
            icon: Icons.payments_outlined,
            title: 'Metode Pembayaran',
            subtitle: 'Transfer, tunai, QRIS, dll.',
            route: '/settings/payment-methods',
          ),
          _Tile(
            icon: Icons.notifications_active_outlined,
            title: 'Preferensi Notifikasi',
            subtitle: 'Pengingat email & WhatsApp',
            route: '/settings/notification-prefs',
          ),
          if (canManageOrg)
            _Tile(
              icon: Icons.group_outlined,
              title: 'Anggota Tim',
              subtitle: 'Undang & kelola akses anggota',
              route: '/settings/team',
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => context.push(route),
      ),
    );
  }
}
