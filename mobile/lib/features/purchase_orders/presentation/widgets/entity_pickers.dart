import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../customers/data/customer_models.dart';
import '../../../customers/data/customers_api.dart';
import '../../../products/data/product_models.dart';
import '../../../products/data/products_api.dart';

/// Bottom sheet pencarian pelanggan. Return [Customer] yang dipilih.
Future<Customer?> showCustomerPicker(BuildContext context) =>
    showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SearchSheet<Customer>(kind: _PickerKind.customer),
    );

/// Bottom sheet pencarian produk aktif. Return [Product] yang dipilih.
Future<Product?> showProductPicker(BuildContext context) =>
    showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SearchSheet<Product>(kind: _PickerKind.product),
    );

enum _PickerKind { customer, product }

/// Bottom sheet quick-add pelanggan baru (nama + HP opsional).
/// Return [Customer] yang baru dibuat, atau null bila dibatalkan.
Future<Customer?> showCustomerFormSheet(
  BuildContext context, {
  String initialName = '',
}) =>
    showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CustomerFormSheet(initialName: initialName),
    );

class _CustomerFormSheet extends ConsumerStatefulWidget {
  const _CustomerFormSheet({required this.initialName});

  final String initialName;

  @override
  ConsumerState<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<_CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final customer = await ref.read(customersApiProvider).create(
            CustomerInput(
              name: _name.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pelanggan "${customer.name}" ditambahkan.')));
      Navigator.of(context).pop(customer);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tambah Pelanggan Baru',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration:
                  const InputDecoration(labelText: 'Nama Pelanggan *'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama pelanggan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'No. HP (opsional)', hintText: '08xxxxxxxxxx'),
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
                  : const Text('Simpan Pelanggan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends ConsumerStatefulWidget {
  const _SearchSheet({super.key, required this.kind});

  final _PickerKind kind;

  @override
  ConsumerState<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends ConsumerState<_SearchSheet<T>> {
  Timer? _debounce;
  final _searchController = TextEditingController();
  String _query = '';
  bool _loading = true;
  String? _error;
  List<Object> _results = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<Object> items;
      if (widget.kind == _PickerKind.customer) {
        final page =
            await ref.read(customersApiProvider).list(search: _query);
        items = page.items;
      } else {
        final page = await ref
            .read(productsApiProvider)
            .list(search: _query, isActive: true);
        items = page.items;
      }
      if (mounted) {
        setState(() {
          _results = items;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value.trim());
      _load();
    });
  }

  Future<void> _createCustomer() async {
    final created = await showCustomerFormSheet(
      context,
      initialName: _searchController.text.trim(),
    );
    if (created != null && mounted) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = widget.kind == _PickerKind.customer;
    final canCreate = isCustomer && _searchController.text.trim().isNotEmpty;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText:
                    isCustomer ? 'Cari pelanggan…' : 'Cari produk…',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          if (canCreate)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _createCustomer,
                  icon: const Icon(Icons.person_add_alt_1, size: 18),
                  label: Text(
                    'Tambah "${_searchController.text.trim()}" sebagai pelanggan baru',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Builder(builder: (context) {
              if (_loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_error != null) {
                return Center(child: Text(_error!));
              }
              if (_results.isEmpty) {
                return Center(
                  child: Text(
                    isCustomer
                        ? 'Pelanggan tidak ditemukan'
                        : 'Produk tidak ditemukan',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  if (item is Customer) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.phone ?? item.email ?? '-'),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  }
                  final product = item as Product;
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        '${formatRupiah(product.price)} / ${product.unit}'),
                    onTap: () => Navigator.of(context).pop(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
