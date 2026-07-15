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
  bool _changePassword = false;
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
      context.pop();
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
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ganti password'),
              value: _changePassword,
              onChanged: (v) => setState(() => _changePassword = v),
            ),
            if (_changePassword) ...[
              TextFormField(
                controller: _currentPassword,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password Saat Ini *',
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
