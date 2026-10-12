import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/settings_api.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _fullName = TextEditingController(
      text: ref.read(authProvider).user?.fullName ?? '');
  late final _phone =
      TextEditingController(text: ref.read(authProvider).user?.phone ?? '');
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _newPasswordConfirmation = TextEditingController();
  /// Password direset admin — form ganti password wajib & tak bisa ditutup.
  late final bool _forced =
      ref.read(authProvider).user?.mustChangePassword ?? false;
  late bool _changePassword = _forced;
  bool _obscure = true;
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _newPasswordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });
    try {
      await ref.read(settingsApiProvider).updateProfile(
            fullName: _fullName.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            currentPassword:
                _changePassword ? _currentPassword.text : null,
            newPassword: _changePassword ? _newPassword.text : null,
            newPasswordConfirmation:
                _changePassword ? _newPasswordConfirmation.text : null,
          );
      // Segarkan data user di state auth.
      await ref.read(authProvider.notifier).refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')));
      // Pada mode wajib ganti password layar ini dibuka lewat redirect
      // (tanpa riwayat), jadi tidak ada yang bisa di-pop.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    } on ApiException catch (e) {
      setState(() => _fieldErrors = e.fieldErrors);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_forced ? 'Buat Password Baru' : 'Profil Saya'),
        automaticallyImplyLeading: !_forced,
        actions: [
          if (_forced)
            TextButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              child: const Text('Keluar'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_forced) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text(
                  'Password Anda telah direset oleh admin. Demi keamanan, '
                  'ganti password sementara sebelum melanjutkan.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _fullName,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap *',
                errorText: _fieldErrors['full_name']?.first,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'No. HP / WhatsApp',
                errorText: _fieldErrors['phone']?.first,
              ),
            ),
            const SizedBox(height: 8),
            if (!_forced)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ganti password'),
                value: _changePassword,
                onChanged: (v) => setState(() => _changePassword = v),
              )
            else
              const SizedBox(height: 8),
            if (_changePassword) ...[
              TextFormField(
                controller: _currentPassword,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText:
                      _forced ? 'Password Sementara *' : 'Password Saat Ini *',
                  errorText: _fieldErrors['current_password']?.first,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => _changePassword && (v == null || v.isEmpty)
                    ? 'Password saat ini wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassword,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password Baru *',
                  errorText: _fieldErrors['new_password']?.first,
                ),
                validator: (v) {
                  if (!_changePassword) return null;
                  if (v == null || v.isEmpty) return 'Password baru wajib diisi';
                  if (v.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordConfirmation,
                obscureText: _obscure,
                decoration:
                    const InputDecoration(labelText: 'Ulangi Password Baru *'),
                validator: (v) => _changePassword && v != _newPassword.text
                    ? 'Password tidak sama'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Simpan'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Email login tidak dapat diubah dari aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
