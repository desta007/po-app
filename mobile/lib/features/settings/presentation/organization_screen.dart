import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/config/env.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/settings_api.dart';
import '../data/settings_models.dart';

class OrganizationScreen extends ConsumerStatefulWidget {
  const OrganizationScreen({super.key});

  @override
  ConsumerState<OrganizationScreen> createState() =>
      _OrganizationScreenState();
}

class _OrganizationScreenState extends ConsumerState<OrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _initialized = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _fill(Organization org) {
    if (_initialized) return;
    _initialized = true;
    _name.text = org.name;
    _phone.text = org.phone ?? '';
    _address.text = org.address ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(settingsApiProvider).updateOrganization(
            name: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            address:
                _address.text.trim().isEmpty ? null : _address.text.trim(),
          );
      ref.invalidate(organizationProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data organisasi disimpan.')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _uploadLogo() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;
    try {
      await ref.read(settingsApiProvider).uploadLogo(picked.path);
      ref.invalidate(organizationProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Logo diperbarui.')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _deleteLogo() async {
    try {
      await ref.read(settingsApiProvider).deleteLogo();
      ref.invalidate(organizationProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(organizationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Organisasi')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: e is ApiException ? e.message : 'Gagal memuat data.',
          onRetry: () => ref.invalidate(organizationProvider),
        ),
        data: (org) {
          _fill(org);
          final catalogUrl = (Env.catalogBaseUrl.isNotEmpty &&
                  (org.slug?.isNotEmpty ?? false))
              ? '${Env.catalogBaseUrl}/catalog/${org.slug}'
              : null;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _uploadLogo,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: org.logoUrl?.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: org.logoUrl!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover)
                              : Container(
                                  width: 110,
                                  height: 110,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  child: const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          color: AppColors.primary),
                                      SizedBox(height: 4),
                                      Text('Logo',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      if (org.logoUrl?.isNotEmpty == true)
                        TextButton(
                          onPressed: _deleteLogo,
                          child: const Text('Hapus logo',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _name,
                  decoration:
                      const InputDecoration(labelText: 'Nama Usaha *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama usaha wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _save,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
                if (catalogUrl != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => SharePlus.instance.share(ShareParams(
                        text:
                            'Lihat katalog ${org.name}: $catalogUrl')),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Link Katalog Online'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
