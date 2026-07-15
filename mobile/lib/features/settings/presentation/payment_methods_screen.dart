import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_states.dart';
import '../data/settings_api.dart';
import '../data/settings_models.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  List<PaymentMethodItem>? _methods;
  bool _saving = false;

  Future<void> _save() async {
    if (_methods == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(settingsApiProvider).updatePaymentMethods(_methods!);
      ref.invalidate(paymentMethodsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Metode pembayaran disimpan.')));
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

  Future<void> _addMethod() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Metode Pembayaran'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Nama metode', hintText: 'Transfer BCA / QRIS / Tunai'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      _methods = [...?_methods, PaymentMethodItem(name: name)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMethod,
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(
          message: e is ApiException ? e.message : 'Gagal memuat data.',
          onRetry: () => ref.invalidate(paymentMethodsProvider),
        ),
        data: (methods) {
          _methods ??= List.of(methods);
          final items = _methods!;
          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const EmptyView(
                        icon: Icons.payments_outlined,
                        title: 'Belum ada metode pembayaran',
                        subtitle: 'Tambahkan dengan tombol +',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final method = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: SwitchListTile(
                              title: Text(method.name),
                              subtitle: Text(
                                method.isActive ? 'Aktif' : 'Nonaktif',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                              value: method.isActive,
                              onChanged: (v) => setState(() {
                                items[index] = method.copyWith(isActive: v);
                              }),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20),
                                onPressed: () => setState(
                                    () => items.removeAt(index)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: FilledButton(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
