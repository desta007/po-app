import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_states.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/settings_api.dart';
import '../data/settings_models.dart';

class TeamMembersScreen extends ConsumerWidget {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(teamMembersProvider);
    final myEmail = ref.watch(authProvider).user?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Anggota Tim')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _invite(context, ref),
        child: const Icon(Icons.person_add_alt),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: e is ApiException ? e.message : 'Gagal memuat data.',
          onRetry: () => ref.invalidate(teamMembersProvider),
        ),
        data: (members) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teamMembersProvider);
            await ref.read(teamMembersProvider.future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final isSelf = member.userEmail == myEmail;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      member.userName.isNotEmpty
                          ? member.userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(member.userName + (isSelf ? ' (Anda)' : '')),
                  subtitle: Text(member.userEmail,
                      style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: member.role == 'owner'
                          ? AppColors.warningLight
                          : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(member.roleLabel ?? member.role,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  onTap: isSelf || member.role == 'owner'
                      ? null
                      : () => _memberActions(context, ref, member),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final email = TextEditingController();
    var role = MemberRole.staff;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Undang Anggota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email (harus sudah terdaftar)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MemberRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [
                  for (final r in MemberRole.values)
                    if (r != MemberRole.owner)
                      DropdownMenuItem(value: r, child: Text(r.label)),
                ],
                onChanged: (v) => setState(() => role = v ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Undang')),
          ],
        ),
      ),
    );
    if (confirmed != true || email.text.trim().isEmpty) return;
    try {
      await ref
          .read(settingsApiProvider)
          .inviteTeamMember(email: email.text.trim(), role: role.name);
      ref.invalidate(teamMembersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anggota berhasil diundang.')));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _memberActions(
      BuildContext context, WidgetRef ref, TeamMember member) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(member.userName,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final r in MemberRole.values)
              if (r != MemberRole.owner && r.name != member.role)
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text('Jadikan ${r.label}'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await ref
                          .read(settingsApiProvider)
                          .updateMemberRole(member.id, r.name);
                      ref.invalidate(teamMembersProvider);
                    } on ApiException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message)));
                      }
                    }
                  },
                ),
            ListTile(
              leading:
                  const Icon(Icons.person_remove, color: AppColors.danger),
              title: const Text('Keluarkan dari tim',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () async {
                Navigator.of(ctx).pop();
                try {
                  await ref
                      .read(settingsApiProvider)
                      .removeMember(member.id);
                  ref.invalidate(teamMembersProvider);
                } on ApiException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)));
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
