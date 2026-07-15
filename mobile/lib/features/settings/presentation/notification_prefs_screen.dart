import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/settings_api.dart';
import '../data/settings_models.dart';

class NotificationPrefsScreen extends ConsumerStatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  ConsumerState<NotificationPrefsScreen> createState() =>
      _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState
    extends ConsumerState<NotificationPrefsScreen> {
  NotificationPrefs? _prefs;
  bool _saving = false;

  Future<void> _save() async {
    if (_prefs == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(settingsApiProvider).updateNotificationPrefs(_prefs!);
      ref.invalidate(organizationProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preferensi notifikasi disimpan.')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickTime() async {
    final parts = (_prefs!.reminderTime).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked =
        await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => _prefs = _prefs!.copyWith(
          reminderTime:
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(organizationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferensi Notifikasi')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: e is ApiException ? e.message : 'Gagal memuat data.',
          onRetry: () => ref.invalidate(organizationProvider),
        ),
        data: (org) {
          _prefs ??= org.notificationPrefs;
          final prefs = _prefs!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Pengingat Email'),
                      subtitle: const Text(
                          'Kirim pengingat jadwal kirim via email'),
                      value: prefs.emailReminder,
                      onChanged: (v) => setState(() =>
                          _prefs = prefs.copyWith(emailReminder: v)),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Pengingat WhatsApp'),
                      subtitle:
                          const Text('Kirim pengingat via WhatsApp'),
                      value: prefs.waReminder,
                      onChanged: (v) => setState(
                          () => _prefs = prefs.copyWith(waReminder: v)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Jam Pengingat'),
                      subtitle:
                          const Text('Waktu pengiriman pengingat harian'),
                      trailing: Text(prefs.reminderTime,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
